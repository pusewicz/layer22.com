# frozen_string_literal: true

module Layer22
  module Components
    module Shared
      class PostListItem < Base
        def initialize(site:, post:)
          super(site:)
          @post = post
        end

        def view_template
          p(class: "post-list-item") do
            a(href: @post.permalink) { strong { @post.title } }
            br
            whitespace
            render PostMeta.new(site:, post: @post)
          end
        end
      end
    end
  end
end
