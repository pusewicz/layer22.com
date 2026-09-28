# frozen_string_literal: true

require "test_helper"

module Layer22
  module Content
    class DataFilesTest < TestCase
      def test_load_all_reads_the_fixture_data_file_keyed_by_basename
        data = in_fixture_site { DataFiles.load_all("_data") }

        assert_equal ["links"], data.keys
        assert_equal "Links", data["links"]["title"]
        assert_equal %w[one two], data["links"]["items"]
      end

      def test_load_all_defaults_to_the_data_directory
        assert_equal ["links"], in_fixture_site { DataFiles.load_all }.keys
      end

      def test_load_all_permits_dates_and_times
        data = in_fixture_site { DataFiles.load_all("_data") }

        assert_equal Date.new(2021, 5, 1), data["links"]["day"]

        with_site({"_data/moments.yml" => "at: 2021-05-01 09:30:00 +0200\n"}) do
          assert_equal Time.utc(2021, 5, 1, 7, 30), DataFiles.load_all("_data")["moments"]["at"]
        end
      end

      def test_load_all_reads_both_yml_and_yaml_files
        with_site({"_data/one.yml" => "n: 1\n", "_data/two.yaml" => "n: 2\n"}) do
          assert_equal({"one" => {"n" => 1}, "two" => {"n" => 2}}, DataFiles.load_all("_data"))
        end
      end

      def test_load_all_orders_files_by_name
        with_site({"_data/b.yml" => "n: 2\n", "_data/c.yaml" => "n: 3\n", "_data/a.yml" => "n: 1\n"}) do
          assert_equal %w[a b c], DataFiles.load_all("_data").keys
        end
      end

      def test_load_all_ignores_other_extensions_and_subdirectories
        files = {
          "_data/keep.yml" => "n: 1\n",
          "_data/notes.txt" => "n: 2\n",
          "_data/data.json" => "{}",
          "_data/nested/deep.yml" => "n: 3\n"
        }

        with_site(files) do
          assert_equal ["keep"], DataFiles.load_all("_data").keys
        end
      end

      def test_load_all_names_a_file_with_dots_by_everything_before_the_last_extension
        with_site({"_data/site.settings.yml" => "n: 1\n"}) do
          assert_equal ["site.settings"], DataFiles.load_all("_data").keys
        end
      end

      def test_load_all_reads_from_the_given_directory
        with_site({"elsewhere/x.yml" => "n: 1\n", "_data/y.yml" => "n: 2\n"}) do
          assert_equal({"x" => {"n" => 1}}, DataFiles.load_all("elsewhere"))
        end
      end

      def test_load_all_returns_an_empty_hash_without_data_files
        with_site do
          assert_equal({}, DataFiles.load_all("_data"))
        end
      end

      def test_load_all_refuses_arbitrary_yaml_objects
        with_site({"_data/bad.yml" => "pattern: !ruby/regexp /x/\n"}) do
          assert_raises(Psych::DisallowedClass) { DataFiles.load_all("_data") }
        end
      end

      def test_load_all_raises_for_invalid_yaml
        with_site({"_data/bad.yml" => "items: [unclosed\n"}) do
          assert_raises(Psych::SyntaxError) { DataFiles.load_all("_data") }
        end
      end
    end
  end
end
