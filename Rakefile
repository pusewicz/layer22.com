desc "Ping all search engines with the new sitemap"
task :ping do
  require 'uri'
  require 'net/http'
  sitemap_url = URI.escape("http://www.layer22.com/sitemap.xml")
  {
    :google         => "http://www.google.com/webmasters/tools/ping?sitemap=%s",
    :bing           => "http://www.bing.com/webmaster/ping.aspx?siteMap=%s",
    :sitemap_writer => "http://www.sitemapwriter.com/notify.php?crawler=all&url=%s"
  }.each do |type, site_url|
    puts "Pinging #{type}..."
    uri     = URI.parse(site_url % sitemap_url)
    http    = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)
    if response.code.to_s =~ /200|301/
      puts "Pinged #{type} Successfully - #{Time.now}"
    else
      puts "Error pinging #{type}! (response code: #{response.code})- #{Time.now}"
    end
  end
end

desc "Builds and deploys to GitHub"
task :deploy do
  sh "bundle exec middleman build"
  sh "bundle exec middleman deploy"
end
