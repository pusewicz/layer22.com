# frozen_string_literal: true

module Layer22
  module Components
    module Pages
      # A page from _pages/ rendered in the "page" layout. A page whose front
      # matter names a +listing+ (tils, tags or categories) gets that listing
      # appended after its own content.
      class StaticPage < Base
        LISTINGS = %w[tils tags categories].freeze

        def initialize(site:, page:)
          super(site:)
          @page = page
          @listing = page.front_matter["listing"]
          return if @listing.nil? || LISTINGS.include?(@listing)

          raise ArgumentError, "#{page.relative_path}: unknown listing #{@listing.inspect}"
        end

        def view_template
          render Layouts::ApplicationLayout.new(
            site:,
            layout: "page",
            title: @page.title,
            seo: {url: @page.permalink, description: @page.description, modified_at: @page.last_modified_at}
          ) do
            article(class: "page w-full bg-[#F5F3F0]") do
              div(class: "max-w-[1080px] mx-auto px-6 pt-12 pb-8 page-body") do
                raw safe(@page.body_html)
                listing
              end
            end
          end
        end

        private

        def listing
          case @listing
          when "tils" then render Shared::PostList.new(site:, posts: site.tils, list_class: "posts")
          when "tags" then render Shared::TaxonomyListing.new(site:, taxonomy: "Tags", groups: site.tags)
          when "categories" then render Shared::TaxonomyListing.new(site:, taxonomy: "Categories", groups: site.categories)
          end
        end
      end
    end
  end
end
