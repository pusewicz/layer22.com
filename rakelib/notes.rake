# frozen_string_literal: true

require "cgi"
require "fileutils"
require "json"
require "net/http"
require "uri"
require "yaml"

# Turns pasted text into a note in `_notes/`. A URL at the start or end of the
# text becomes the note's link card; its metadata and thumbnail are fetched
# once, here, so site builds never touch the network. YouTube videos keep only
# their id: the site shows YouTube's own thumbnail and player for them.
module Notes
  # Raised when a note cannot be created from the given input.
  class Error < StandardError; end

  URL = %r{https?://[^\s<>]+}
  LEADING_URL = /\A(#{URL})(?=\s|\z)/
  TRAILING_URL = /(?<=\A|\s)(#{URL})\z/
  TRAILING_PUNCTUATION = /[.,;:!?'"]+\z/
  USER_AGENT = "Mozilla/5.0 (compatible; layer22-notes/1.0; +https://layer22.com/notes/)"
  YOUTUBE_HOSTS = %w[youtube.com www.youtube.com m.youtube.com music.youtube.com youtu.be].freeze
  YOUTUBE_ID = /\A[\w-]{11}\z/
  IMAGE_EXTENSIONS = {
    "image/avif" => ".avif",
    "image/gif" => ".gif",
    "image/jpeg" => ".jpg",
    "image/png" => ".png",
    "image/webp" => ".webp"
  }.freeze
  MAX_IMAGE_BYTES = 5 * 1024 * 1024
  DESCRIPTION_LENGTH = 200
  # Skips fenced code blocks and code spans so only bare URLs in prose match.
  AUTOLINK = /
    ^(?<fence>`{3,}|~{3,})[^\n]*\n.*?^\k<fence>[ \t]*$
    | (?<ticks>`+).+?\k<ticks>
    | (?<!\]\(|[<"'=])(?<url>#{URL})
  /mx

  module_function

  # Writes a note for +text+ and returns its path.
  #
  # @param text [String] the pasted note, in Markdown
  # @param time [Time] when the note was written
  # @return [String] path of the created note
  def create(text, time: Time.now)
    body, url = split_link(text)
    raise Error, "Nothing to note" if body.empty? && url.nil?

    basename = time.strftime("%Y-%m-%d-%H%M%S")
    path = File.join("_notes", time.strftime("%Y/%m"), "#{basename}.md")
    raise Error, "#{path} already exists" if File.exist?(path)

    front_matter = "date: #{time.strftime("%Y-%m-%d %H:%M:%S %z")}\n"
    front_matter += {"link" => fetch_link(url, basename)}.to_yaml.delete_prefix("---\n") if url

    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, "---\n#{front_matter}---\n\n#{autolink(body)}\n")
    path
  end

  # Splits a URL standing at the start or end of +text+ off from the rest.
  #
  # @param text [String]
  # @return [Array(String, String), Array(String, nil)] the remaining body and the URL, if any
  def split_link(text)
    text = text.strip
    if (match = text.match(LEADING_URL))
      [match.post_match.strip, trim_url(match[1]).first]
    elsif (match = text.match(TRAILING_URL))
      [match.pre_match.strip, trim_url(match[1]).first]
    else
      [text, nil]
    end
  end

  # Wraps bare URLs in angle brackets, since kramdown does not autolink them.
  #
  # @param text [String] Markdown
  # @return [String]
  def autolink(text)
    text.gsub(AUTOLINK) do
      match = Regexp.last_match
      next match[0] unless match[:url]

      url, rest = trim_url(match[:url])
      "<#{url}>#{rest}"
    end
  end

  # Separates punctuation that ends a sentence from the URL it follows.
  #
  # @param url [String]
  # @return [Array(String, String)] the URL and the trailing punctuation
  def trim_url(url)
    rest = +""
    loop do
      if (match = url.match(TRAILING_PUNCTUATION))
        rest.prepend(match[0])
        url = match.pre_match
      elsif url.end_with?(")") && url.count(")") > url.count("(")
        rest.prepend(")")
        url = url.chop
      else
        return [url, rest]
      end
    end
  end

  # Fetches the card metadata for +url+, falling back to the bare URL. YouTube
  # links get no thumbnail download; videos record their id instead, so the
  # site can show YouTube's own thumbnail and player.
  #
  # @param url [String]
  # @param basename [String] file name, without extension, for the thumbnail
  # @return [Hash{String => String}] url, site, and when available youtube, title, author, description and image
  def fetch_link(url, basename)
    link = {"url" => url, "site" => URI(url).host.delete_prefix("www.")}
    video = youtube_id(url)
    link["youtube"] = video if video
    metadata = youtube?(url) ? youtube_metadata(url) : page_metadata(url)
    image_urls = metadata.delete("image_urls")
    link.merge!(metadata.reject { |_, value| value.to_s.strip.empty? })
    image = download_image(image_urls, basename) if image_urls&.any?
    link["image"] = image if image
    link
  rescue => e
    warn "Could not fetch #{url}: #{e.message}"
    link || {"url" => url}
  end

  # @param url [String]
  # @return [Boolean]
  def youtube?(url)
    YOUTUBE_HOSTS.include?(URI(url).host)
  end

  # Returns the video id of a YouTube watch, youtu.be, Shorts, live or embed URL.
  #
  # @param url [String]
  # @return [String, nil]
  def youtube_id(url)
    return unless youtube?(url)

    uri = URI(url)
    id = if uri.host == "youtu.be"
      uri.path.split("/")[1]
    elsif uri.path == "/watch"
      URI.decode_www_form(uri.query.to_s).assoc("v")&.last
    else
      uri.path[%r{\A/(?:shorts|live|embed|v)/([^/]+)}, 1]
    end
    id if id&.match?(YOUTUBE_ID)
  end

  # Reads a YouTube video's metadata from its oEmbed endpoint, which unlike
  # the watch page is not behind a cookie consent wall.
  #
  # @param url [String]
  # @return [Hash{String => Object}]
  def youtube_metadata(url)
    body, = get("https://www.youtube.com/oembed?format=json&url=#{CGI.escape(url)}")
    data = JSON.parse(body.force_encoding(Encoding::UTF_8))
    {
      "title" => data["title"],
      "site" => data["provider_name"],
      "author" => data["author_name"]
    }
  end

  # Reads a page's Open Graph metadata, falling back to Twitter cards and <title>.
  #
  # @param url [String]
  # @return [Hash{String => Object}]
  def page_metadata(url)
    require "nokogiri"

    body, final_url, content_type = get(url)
    raise "not an HTML page (#{content_type})" unless content_type.to_s.include?("html")

    document = Nokogiri::HTML(body)
    meta = lambda do |*names|
      names.each do |name|
        content = document.at_css(%(meta[property="#{name}"], meta[name="#{name}"]))&.[]("content")&.strip
        return content unless content.nil? || content.empty?
      end
      nil
    end
    image = meta.call("og:image:secure_url", "og:image", "twitter:image")
    description = meta.call("og:description", "twitter:description", "description")

    {
      "title" => meta.call("og:title", "twitter:title") || document.at_css("title")&.text&.strip,
      "site" => meta.call("og:site_name"),
      "description" => description && truncate(description, DESCRIPTION_LENGTH),
      "image_urls" => image ? [URI.join(final_url, image).to_s] : []
    }
  end

  # Saves the first of +urls+ that is an image to `images/notes/`.
  #
  # @param urls [Array<String>] candidates, best first
  # @param basename [String] file name without extension
  # @return [String, nil] site path of the saved image
  def download_image(urls, basename)
    failures = urls.map do |url|
      body, _, content_type = get(url)
      extension = IMAGE_EXTENSIONS[content_type]
      next "#{url}: #{content_type} is not a supported image" unless extension
      next "#{url}: larger than #{MAX_IMAGE_BYTES} bytes" if body.bytesize > MAX_IMAGE_BYTES

      path = File.join("images", "notes", "#{basename}#{extension}")
      FileUtils.mkdir_p(File.dirname(path))
      File.binwrite(path, body)
      return "/#{path}"
    rescue => e
      "#{url}: #{e.message}"
    end
    warn "Could not download a thumbnail:", *failures.map { |failure| "  #{failure}" }
    nil
  end

  # GETs +url+, following redirects.
  #
  # @param url [String]
  # @param redirects [Integer] how many more redirects to follow
  # @return [Array(String, String, String)] body, final URL and content type
  def get(url, redirects: 5)
    uri = URI(url)
    response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https", open_timeout: 10, read_timeout: 10) do |http|
      http.get(uri.request_uri, "User-Agent" => USER_AGENT, "Accept-Language" => "en")
    end

    case response
    when Net::HTTPSuccess
      [response.body, url, response.content_type]
    when Net::HTTPRedirection
      raise "too many redirects" if redirects.zero?

      get(URI.join(url, response["location"]).to_s, redirects: redirects - 1)
    else
      raise "#{response.code} #{response.message}"
    end
  end

  # Shortens +text+ to at most +length+ characters, breaking between words.
  #
  # @param text [String]
  # @param length [Integer]
  # @return [String]
  def truncate(text, length)
    return text if text.length <= length

    "#{text[0, length - 1].sub(/\s+\S*\z/, "")}…"
  end
end

desc "Create a note from the clipboard, or from stdin when piped"
task :note do
  text = $stdin.tty? ? IO.popen(["pbpaste"], &:read) : $stdin.read
  puts "Created #{Notes.create(text)}"
rescue Notes::Error, Errno::ENOENT => e
  abort e.message
end
