# frozen_string_literal: true

module Layer22
  module Components
    module Shared
      # Posts grouped by tag or category, with a jump menu to each group.
      class TaxonomyListing < Base
        # +groups+ maps each tag or category name to its posts.
        def initialize(site:, taxonomy:, groups:)
          super(site:)
          @taxonomy = taxonomy
          @groups = groups
        end

        def view_template
          nav(class: "menu browse by-#{slugify(@taxonomy)}", aria_label: @taxonomy) do
            strong(aria_hidden: "true") { "Jump to:" }
            @groups.each_key do |name|
              whitespace
              a(href: "##{slugify(name)}") { name }
            end
          end
          @groups.each do |name, posts|
            h2(id: slugify(name)) { a(href: "/tags/#{name}") { name } }
            render PostList.new(site:, posts:, label: "posts classified under #{name}")
          end
        end
      end
    end
  end
end
