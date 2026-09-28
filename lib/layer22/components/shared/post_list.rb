# frozen_string_literal: true

module Layer22
  module Components
    module Shared
      # A list of posts, each with its date and reading time.
      class PostList < Base
        def initialize(site:, posts:, list_class: nil, label: nil)
          super(site:)
          @posts = posts
          @list_class = list_class
          @label = label
        end

        def view_template
          ul(class: @list_class, aria_label: @label) do
            @posts.each do |post|
              li { render PostListItem.new(site:, post:) }
            end
          end
        end
      end
    end
  end
end
