# frozen_string_literal: true

desc "Create a new TIL post"
task :til, [:title] do |_t, args|
  title = args[:title] || "New TIL"
  date = Time.now

  template = <<~TEMPLATE
    ---
    title: "#{title}"
    date: #{date.strftime("%Y-%m-%d %H:%M:%S %z")}
    tags: []
    ---

    <!-- Add your TIL content here -->
  TEMPLATE

  dest = "_til/#{date.year}/#{date.strftime("%m")}/#{date.strftime("%Y-%m-%d")}-#{title.downcase.gsub(/\s+/, "-")}.md"
  mkdir_p File.dirname(dest)
  puts "Creating new TIL post at #{dest}"
  File.write(dest, template)
end

desc "Create a new blog post"
task :post, [:title] do |_t, args|
  title = args[:title] || "New Post"
  date = Time.now
  slug = title.downcase.gsub(/[^a-z0-9]+/, "-").gsub(/^-|-$/, "")

  template = <<~TEMPLATE
    ---
    title: "#{title}"
    date: #{date.strftime("%Y-%m-%d %H:%M:%S %z")}
    slug: #{slug}
    tags: []
    ---

    <!-- Add your post content here -->
  TEMPLATE

  dest = "_posts/#{date.strftime("%Y-%m-%d")}-#{slug}.md"
  puts "Creating new post at #{dest}"
  File.write(dest, template)
end
