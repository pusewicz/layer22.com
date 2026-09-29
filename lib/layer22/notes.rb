# frozen_string_literal: true

require "cgi/escape"
require "fastimage"
require "fileutils"
require "json"
require "net/http"
require "stringio"
require "time"
require "uri"
require "yaml"

module Layer22
  # Turns pasted text into a note in `_notes/`. A URL at the start or end of the
  # text becomes the note's link card; its metadata and thumbnail are fetched
  # once, here, so site builds never touch the network. YouTube videos keep only
  # their id: the site shows YouTube's own thumbnail and player for them. Bluesky
  # posts keep the post itself (its text, date and first image), which the site
  # renders without contacting Bluesky. Instagram posts keep the caption, author
  # and thumbnail for a card that links to the post.
  module Notes
    # Raised when a note cannot be created from the given input.
    class Error < StandardError; end

    URL = %r{https?://[^\s<>]+}
    LEADING_URL = /\A(#{URL})(?=\s|\z)/
    TRAILING_URL = /(?<=\A|\s)(#{URL})\z/
    TRAILING_PUNCTUATION = /[.,;:!?'"]+\z/
    TEXT_TYPE = %r{\Atext/|[/+](?:xml|json)\z}
    CLOSING_BRACKETS = {")" => "(", "]" => "["}.freeze
    USER_AGENT = "Mozilla/5.0 (compatible; layer22-notes/1.0; +https://layer22.com/notes/)"
    YOUTUBE_HOSTS = %w[youtube.com www.youtube.com m.youtube.com music.youtube.com youtu.be].freeze
    YOUTUBE_ID = /\A[\w-]{11}\z/
    BLUESKY_HOST = "bsky.app"
    BLUESKY_POST_PATH = %r{\A/profile/(?<actor>[^/]+)/post/(?<rkey>[\w.:~-]+)/?\z}
    BLUESKY_THREAD_API = "https://public.api.bsky.app/xrpc/app.bsky.feed.getPostThread"
    BLUESKY_FACET_URLS = {
      "app.bsky.richtext.facet#link" => ->(feature) { feature["uri"] },
      "app.bsky.richtext.facet#mention" => ->(feature) { "https://bsky.app/profile/#{feature["did"]}" },
      "app.bsky.richtext.facet#tag" => ->(feature) { "https://bsky.app/hashtag/#{CGI.escapeURIComponent(feature["tag"].to_s)}" }
    }.freeze
    INSTAGRAM_HOSTS = %w[instagram.com www.instagram.com].freeze
    INSTAGRAM_POST_PATH = %r{\A/(?:[\w.]+/)?(?<kind>p|reel|tv)/[\w-]+/?\z}
    INSTAGRAM_OEMBED = "https://www.instagram.com/api/v1/oembed/"
    IMAGE_EXTENSIONS = {
      "image/avif" => ".avif",
      "image/gif" => ".gif",
      "image/jpeg" => ".jpg",
      "image/png" => ".png",
      "image/webp" => ".webp"
    }.freeze
    MAX_IMAGE_BYTES = 5 * 1024 * 1024
    DESCRIPTION_LENGTH = 200
    # Skips fenced code blocks, code spans and Markdown links, so only bare URLs in prose match.
    AUTOLINK = /
      ^(?<fence>`{3,}|~{3,})[^\n]*\n.*?^\k<fence>[ \t]*$
      | (?<ticks>`+).+?\k<ticks>
      | !?\[[^\]\n]*\]\([^)\n]*\)
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

    # Separates punctuation that ends a sentence, and any closing bracket its
    # URL did not open, from the URL.
    #
    # @param url [String]
    # @return [Array(String, String)] the URL and the trailing punctuation
    def trim_url(url)
      rest = +""
      loop do
        if (match = url.match(TRAILING_PUNCTUATION))
          rest.prepend(match[0])
          url = match.pre_match
        elsif (opener = CLOSING_BRACKETS[url[-1]]) && url.count(url[-1]) > url.count(opener)
          rest.prepend(url[-1])
          url = url.chop
        else
          return [url, rest]
        end
      end
    end

    # Fetches the card metadata for +url+, falling back to the bare URL. YouTube
    # links get no thumbnail download; videos record their id instead, so the
    # site can show YouTube's own thumbnail and player. Bluesky posts record the
    # post, and Instagram posts their kind and caption; both download an image.
    #
    # @param url [String]
    # @param basename [String] file name, without extension, for the thumbnail
    # @return [Hash{String => Object}] url, site, and when available youtube, title, author, description, bluesky, instagram and image
    def fetch_link(url, basename)
      link = {"url" => url, "site" => URI(url).host.delete_prefix("www.")}
      video = youtube_id(url)
      link["youtube"] = video if video
      metadata = link_metadata(url)
      image_urls = metadata.delete("image_urls")
      link.merge!(metadata.reject { |_, value| value.to_s.strip.empty? })
      image = download_image(image_urls, basename) if image_urls&.any?
      link["image"] = image if image
      link
    rescue => e
      warn "Could not fetch #{url}: #{e.message}"
      link || {"url" => url}
    end

    # Reads the metadata of +url+ from the place that knows most about it.
    #
    # @param url [String]
    # @return [Hash{String => Object}]
    def link_metadata(url)
      if youtube?(url)
        youtube_metadata(url)
      elsif bluesky_post(url)
        bluesky_metadata(url)
      elsif instagram_kind(url)
        instagram_metadata(url)
      else
        page_metadata(url)
      end
    end

    # @param url [String]
    # @return [Boolean]
    def youtube?(url)
      YOUTUBE_HOSTS.include?(URI(url).host&.downcase)
    end

    # Returns the video id of a YouTube watch, youtu.be, Shorts, live or embed URL.
    #
    # @param url [String]
    # @return [String, nil]
    def youtube_id(url)
      return unless youtube?(url)

      uri = URI(url)
      id = if uri.host.downcase == "youtu.be"
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

    # Splits a bsky.app post URL into its author and record key.
    #
    # @param url [String]
    # @return [Array(String, String), nil] the author's handle or DID and the post's record key; nil
    #   for any other URL, including other bsky.app pages such as profiles
    def bluesky_post(url)
      uri = URI(url)
      return unless uri.host&.downcase == BLUESKY_HOST

      match = BLUESKY_POST_PATH.match(uri.path)
      [match[:actor], match[:rkey]] if match
    end

    # Reads a Bluesky post from the public AppView, which needs no login. Bluesky's
    # own pages only carry the author's name and a shortened copy of the text.
    #
    # @param url [String] a bsky.app post URL
    # @return [Hash{String => Object}] site, author, the post under bluesky, and its image_urls
    def bluesky_metadata(url)
      actor, rkey = bluesky_post(url)
      post_uri = CGI.escape("at://#{actor}/app.bsky.feed.post/#{rkey}")
      body, = get("#{BLUESKY_THREAD_API}?uri=#{post_uri}&depth=0&parentHeight=0")
      thread = JSON.parse(body.force_encoding(Encoding::UTF_8)).fetch("thread")
      raise "the post is not available (#{thread["$type"]})" unless thread["$type"] == "app.bsky.feed.defs#threadViewPost"

      post = thread.fetch("post")
      record = post.fetch("record")
      text = record["text"].to_s
      media = bluesky_media(post["embed"])
      details = {
        "handle" => post.dig("author", "handle"),
        "date" => bluesky_date(record["createdAt"]),
        "lang" => Array(record["langs"]).first,
        "text" => text,
        "alt" => media[:alt],
        "facets" => bluesky_facets(text, record["facets"])
      }
      {
        "site" => "Bluesky",
        "author" => post.dig("author", "displayName"),
        "bluesky" => details.reject { |_, value| Array(value).all? { |item| item.to_s.strip.empty? } },
        "image_urls" => [media[:image]].compact
      }
    end

    # Finds the first picture a post shows: an image, gallery or video thumbnail,
    # or the preview image of a link. Quoted posts have none of their own.
    #
    # @param embed [Hash, nil] the post's embed view
    # @return [Hash{Symbol => String}] the :image URL and its :alt text, when it has them
    def bluesky_media(embed)
      case embed&.fetch("$type", nil)
      when "app.bsky.embed.images#view"
        {image: embed.dig("images", 0, "thumb"), alt: embed.dig("images", 0, "alt")}
      when "app.bsky.embed.gallery#view"
        {image: embed.dig("items", 0, "thumbnail"), alt: embed.dig("items", 0, "alt")}
      when "app.bsky.embed.video#view"
        {image: embed["thumbnail"], alt: embed["alt"]}
      when "app.bsky.embed.external#view"
        {image: embed.dig("external", "thumb")}
      when "app.bsky.embed.recordWithMedia#view"
        bluesky_media(embed["media"])
      else
        {}
      end
    end

    # Normalizes a post's creation time to UTC.
    #
    # @param created_at [String, nil]
    # @return [String, nil] ISO 8601, or nil when it is missing or not a time
    def bluesky_date(created_at)
      Time.iso8601(created_at.to_s).utc.iso8601
    rescue ArgumentError
      nil
    end

    # Turns a post's rich text facets into the links they stand for. Facets
    # locate their text by UTF-8 byte offsets, which become character offsets
    # here so that nothing downstream has to slice bytes. Facets that are not a
    # link, mention or hashtag, that point somewhere other than http(s), or
    # whose offsets do not fall on characters of +text+ are dropped.
    #
    # @param text [String] the post's text
    # @param facets [Array<Hash>, nil] the post's facets
    # @return [Array<Hash{String => Object}>] from, to (exclusive) and url of each link
    def bluesky_facets(text, facets)
      Array(facets).filter_map do |facet|
        index = facet["index"]
        first = index&.fetch("byteStart", nil)
        last = index&.fetch("byteEnd", nil)
        next unless first.is_a?(Integer) && last.is_a?(Integer) && first >= 0 && first < last && last <= text.bytesize

        linked = text.byteslice(first, last - first)
        next unless linked.valid_encoding? && text.byteslice(0, first).valid_encoding?

        url = Array(facet["features"]).filter_map { |feature| BLUESKY_FACET_URLS[feature["$type"]]&.call(feature) }.first
        next unless url&.match?(%r{\Ahttps?://}i)

        start = text.byteslice(0, first).length
        {"from" => start, "to" => start + linked.length, "url" => url}
      end
    end

    # Tells what an Instagram URL points at.
    #
    # @param url [String]
    # @return [String, nil] "reel" for a reel or IGTV video and "post" for any other post; nil for
    #   any other URL, including Instagram profiles and stories
    def instagram_kind(url)
      uri = URI(url)
      return unless INSTAGRAM_HOSTS.include?(uri.host&.downcase)

      case INSTAGRAM_POST_PATH.match(uri.path)&.[](:kind)
      when "p" then "post"
      when "reel", "tv" then "reel"
      end
    end

    # Reads an Instagram post from Instagram's oEmbed endpoint, which unlike the
    # post's page needs no login and carries the whole, uncropped thumbnail.
    #
    # @param url [String] an Instagram post or reel URL
    # @return [Hash{String => Object}] site, the kind of post under instagram, author, description
    #   (the caption on one line) and image_urls
    def instagram_metadata(url)
      body, _, content_type = get("#{INSTAGRAM_OEMBED}?url=#{CGI.escape(url)}")
      raise "not JSON (#{content_type})" unless content_type.to_s.include?("json")

      data = JSON.parse(body.force_encoding(Encoding::UTF_8))
      {
        "site" => "Instagram",
        "instagram" => instagram_kind(url),
        "author" => data["author_name"],
        "description" => truncate(data["title"].to_s.gsub(/\s+/, " ").strip, DESCRIPTION_LENGTH),
        "image_urls" => [data["thumbnail_url"]].compact
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

    # Saves the first of +urls+ that is an image to `images/notes/`. An image served as
    # application/octet-stream is identified from its own bytes.
    #
    # @param urls [Array<String>] candidates, best first
    # @param basename [String] file name without extension
    # @return [String, nil] site path of the saved image
    def download_image(urls, basename)
      failures = urls.map do |url|
        body, _, content_type = get(url)
        extension = IMAGE_EXTENSIONS[content_type]
        extension ||= sniff_extension(body) if content_type == "application/octet-stream"
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

    # Names the file extension of +body+ from the image itself, going by the
    # format FastImage recognizes.
    #
    # @param body [String] binary data
    # @return [String, nil] the extension, or nil when +body+ is not a supported image
    def sniff_extension(body)
      IMAGE_EXTENSIONS["image/#{FastImage.type(StringIO.new(body))}"]
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
        [decode(response), url, response.content_type]
      when Net::HTTPRedirection
        raise "too many redirects" if redirects.zero?

        get(URI.join(url, response["location"]).to_s, redirects: redirects - 1)
      else
        raise "#{response.code} #{response.message}"
      end
    end

    # Returns the body of +response+ tagged with the charset the server declared,
    # so text is parsed as that and not as bytes, with any bytes invalid in it
    # replaced. Images and other binary bodies are left as they are, whatever
    # charset the server labels them with.
    #
    # @param response [Net::HTTPResponse]
    # @return [String, nil]
    def decode(response)
      body = response.body
      charset = response.type_params["charset"]
      return body unless body && charset && response.content_type.to_s.match?(TEXT_TYPE)

      text = body.dup.force_encoding(charset.delete('"'))
      text.valid_encoding? ? text : text.scrub
    rescue ArgumentError
      body
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
end
