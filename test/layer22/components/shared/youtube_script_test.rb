# frozen_string_literal: true

require "test_helper"

module Layer22
  module Components
    module Shared
      class YoutubeScriptTest < TestCase
        def render_script
          parse_html(YoutubeScript.new.call)
        end

        def test_renders_a_single_script
          assert_equal 1, render_script.css("script").size
        end

        def test_script_is_emitted_verbatim_rather_than_escaped
          script = render_script.at_css("script").text

          assert_equal YoutubeScript::SCRIPT, script
          assert_includes script, "=> {"
          assert_includes script, "`https://www.youtube-nocookie.com/embed/"
        end

        def test_script_swaps_thumbnail_links_for_the_nocookie_player
          script = YoutubeScript::SCRIPT

          assert_includes script, %(closest("a[data-youtube-id]"))
          assert_includes script, "youtube-nocookie.com/embed/${encodeURIComponent(link.dataset.youtubeId)}?autoplay=1"
          assert_includes script, "link.replaceWith(player)"
        end

        def test_script_leaves_modified_and_non_primary_clicks_to_the_browser
          script = YoutubeScript::SCRIPT

          assert_includes script, "event.button !== 0"
          %w[metaKey ctrlKey shiftKey altKey].each { |key| assert_includes script, "event.#{key}" }
        end

        def test_script_titles_the_player_with_the_links_label
          assert_includes YoutubeScript::SCRIPT, %(iframe.title = link.getAttribute("aria-label"))
        end
      end
    end
  end
end
