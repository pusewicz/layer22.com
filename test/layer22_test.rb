# frozen_string_literal: true

require "test_helper"

module Layer22
  class ModuleTest < TestCase
    LIB = File.expand_path("../lib/layer22", __dir__)

    def test_eager_load_loads_every_file_under_lib
      Layer22.loader.eager_load

      assert_equal "Layer22::Content::TIL", Content::TIL.name
      assert_equal "Layer22::Rendering::CSS", Rendering::CSS.name
      assert_equal "Layer22::Components::Shared::SeoHead", Components::Shared::SeoHead.name
      assert_equal "Layer22::Components::Pages::TilPage", Components::Pages::TilPage.name
    end

    def test_loader_inflects_acronym_file_names
      inflector = Layer22.loader.inflector

      assert_equal "TIL", inflector.camelize("til", "#{LIB}/content/til.rb")
      assert_equal "CSS", inflector.camelize("css", "#{LIB}/rendering/css.rb")
      assert_equal "SeoHead", inflector.camelize("seo_head", "#{LIB}/components/shared/seo_head.rb")
      assert_equal "TilPage", inflector.camelize("til_page", "#{LIB}/components/pages/til_page.rb")
    end

    def test_loader_camelizes_other_file_names_normally
      assert_equal "PostListItem", Layer22.loader.inflector.camelize("post_list_item", "#{LIB}/components/shared/post_list_item.rb")
      assert_equal "OutputPath", Layer22.loader.inflector.camelize("output_path", "#{LIB}/output_path.rb")
    end

    def test_loader_is_memoized
      assert_same Layer22.loader, Layer22.loader
    end

    def test_logger_writer_replaces_the_logger
      original = Layer22.logger
      custom = Logger.new(StringIO.new)
      Layer22.logger = custom

      assert_same custom, Layer22.logger
    ensure
      Layer22.logger = original
    end

    def test_default_logger_writes_short_lines_to_stdout
      original = Layer22.logger
      Layer22.instance_variable_set(:@logger, nil)

      out, = capture_io do
        assert_same Layer22.logger, Layer22.logger
        Layer22.logger.info("Reloading code...")
        Layer22.logger.warn("Careful")
      end

      assert_match(/\A\d\d:\d\d:\d\d \[info\] Reloading code\.\.\.\n\d\d:\d\d:\d\d \[warn\] Careful\n\z/, out)
    ensure
      Layer22.logger = original
    end

    def test_managed_files_lists_the_library_files
      files = Layer22.managed_files

      assert_includes files, "#{LIB}/slug.rb"
      assert_includes files, "#{LIB}/content/post.rb"
      assert_includes files, "#{LIB}/components/shared/seo_head.rb"
      assert(files.all? { |file| file.end_with?(".rb") })
    end

    def test_managed_files_leaves_out_the_dev_server
      assert_path_exists "#{LIB}/dev_server.rb"
      refute_includes Layer22.managed_files, "#{LIB}/dev_server.rb"
      assert_equal Dir.glob("#{LIB}/**/*.rb").sort - ["#{LIB}/dev_server.rb"], Layer22.managed_files.sort
    end

    def test_reload_does_nothing_when_no_file_changed
      with_reload_harness(mtimes: [Time.utc(2021, 1, 1)], last_reload_at: Time.utc(2021, 6, 1)) do |reloads, log|
        assert_nil Layer22.reload!

        assert_equal 0, reloads.size
        assert_equal "", log.string
        assert_equal Time.utc(2021, 6, 1), Layer22.instance_variable_get(:@last_reload_at)
      end
    end

    def test_reload_ignores_a_file_last_modified_exactly_at_the_last_reload
      with_reload_harness(mtimes: [Time.utc(2021, 6, 1)], last_reload_at: Time.utc(2021, 6, 1)) do |reloads, _log|
        Layer22.reload!

        assert_equal 0, reloads.size
      end
    end

    def test_reload_reloads_and_logs_when_a_file_changed
      with_reload_harness(mtimes: [Time.utc(2021, 6, 2)], last_reload_at: Time.utc(2021, 6, 1)) do |reloads, log|
        Layer22.reload!

        assert_equal 1, reloads.size
        assert_match(/ INFO -- : Reloading code\.\.\.\n/, log.string)
        assert_operator Layer22.instance_variable_get(:@last_reload_at), :>, Time.utc(2021, 6, 2)
      end
    end

    def test_reload_reloads_once_when_only_some_files_changed
      mtimes = [Time.utc(2021, 5, 1), Time.utc(2021, 6, 2), Time.utc(2021, 4, 1)]

      with_reload_harness(mtimes:, last_reload_at: Time.utc(2021, 6, 1)) do |reloads, _log|
        Layer22.reload!

        assert_equal 1, reloads.size
      end
    end

    def test_reload_does_not_reload_again_until_another_file_changes
      with_reload_harness(mtimes: [Time.utc(2021, 6, 2)], last_reload_at: Time.utc(2021, 6, 1)) do |reloads, _log|
        Layer22.reload!
        Layer22.reload!

        assert_equal 1, reloads.size
      end
    end

    private

    # Runs the block with files last modified at +mtimes+ as the only managed
    # files, a stand-in loader that counts #reload calls (the real one would unload
    # the constants this suite runs under) and a logger writing to a StringIO.
    # Yields the reload calls and the log, and restores the module's state after.
    def with_reload_harness(mtimes:, last_reload_at:)
      reloads = []
      loader = Object.new
      loader.define_singleton_method(:reload) { reloads << :reload }
      log = StringIO.new
      original_logger = Layer22.logger
      original_reload_at = Layer22.instance_variable_get(:@last_reload_at)

      Dir.mktmpdir("layer22-reload") do |dir|
        files = mtimes.each_with_index.map do |mtime, index|
          File.join(dir, "file#{index}.rb").tap do |path|
            File.write(path, "")
            File.utime(mtime, mtime, path)
          end
        end
        Layer22.logger = Logger.new(log)
        Layer22.instance_variable_set(:@last_reload_at, last_reload_at)

        Layer22.stub(:loader, loader) do
          Layer22.stub(:managed_files, files) { yield reloads, log }
        end
      end
    ensure
      Layer22.logger = original_logger
      Layer22.instance_variable_set(:@last_reload_at, original_reload_at)
    end
  end
end
