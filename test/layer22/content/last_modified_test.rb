# frozen_string_literal: true

require "test_helper"
require "shellwords"

module Layer22
  module Content
    # Each test builds its own repository, and its commit messages carry the test
    # name, so no two tests share a HEAD: LastModified caches on HEAD.
    class LastModifiedTest < TestCase
      FIRST = "2021-03-01T10:00:00+0000"
      SECOND = "2021-04-15T18:30:00+0000"
      THIRD = "2021-06-20T07:15:00+0000"
      LONG_AGO = Time.utc(2001, 2, 3, 4, 5, 6)
      GIT_ENV = {"GIT_CONFIG_GLOBAL" => File::NULL, "GIT_CONFIG_NOSYSTEM" => "1"}.freeze

      def test_for_returns_the_time_of_the_last_commit_that_touched_the_file
        with_repo do |repo|
          write_file("_posts/a.md", "one")
          commit(repo, "add a", at: FIRST)
          File.utime(LONG_AGO, LONG_AGO, "_posts/a.md")

          assert_kind_of Time, LastModified.for("_posts/a.md")
          assert_equal Time.utc(2021, 3, 1, 10), LastModified.for("_posts/a.md")
        end
      end

      def test_for_uses_the_newest_commit_for_each_file
        with_repo do |repo|
          write_file("a.md", "one")
          write_file("b.md", "one")
          commit(repo, "add both", at: FIRST)
          write_file("a.md", "two")
          commit(repo, "edit a", at: SECOND)
          write_file("c.md", "one")
          commit(repo, "add c", at: THIRD)

          assert_equal Time.utc(2021, 4, 15, 18, 30), LastModified.for("a.md")
          assert_equal Time.utc(2021, 3, 1, 10), LastModified.for("b.md")
          assert_equal Time.utc(2021, 6, 20, 7, 15), LastModified.for("c.md")
        end
      end

      def test_for_uses_the_commit_time_rather_than_the_author_time
        with_repo do |repo|
          write_file("a.md", "one")
          commit(repo, "add a", at: SECOND, authored: FIRST)

          assert_equal Time.utc(2021, 4, 15, 18, 30), LastModified.for("a.md")
        end
      end

      def test_for_ignores_uncommitted_edits_to_a_committed_file
        with_repo do |repo|
          write_file("a.md", "one")
          commit(repo, "add a", at: FIRST)
          write_file("a.md", "edited but not committed")

          assert_equal Time.utc(2021, 3, 1, 10), LastModified.for("a.md")
        end
      end

      def test_for_finds_files_with_unicode_and_space_in_their_paths_under_an_ascii_locale
        with_repo do |repo|
          write_file("_posts/2021-01-01-café.md", "one")
          write_file("日本語 メモ.md", "one")
          commit(repo, "add unicode", at: FIRST)

          times = with_default_external(Encoding::US_ASCII) do
            [LastModified.for("_posts/2021-01-01-café.md"), LastModified.for("日本語 メモ.md")]
          end

          assert_equal [Time.utc(2021, 3, 1, 10)] * 2, times
        end
      end

      def test_for_falls_back_to_the_mtime_of_an_uncommitted_file
        with_repo do |repo|
          write_file("committed.md", "one")
          commit(repo, "add committed", at: FIRST)
          write_file("new.md", "two")
          File.utime(LONG_AGO, LONG_AGO, "new.md")

          assert_equal LONG_AGO, LastModified.for("new.md")
        end
      end

      def test_for_falls_back_to_the_mtime_in_a_repository_without_commits
        with_repo do
          write_file("a.md", "one")
          File.utime(LONG_AGO, LONG_AGO, "a.md")

          assert_equal LONG_AGO, LastModified.for("a.md")
        end
      end

      def test_for_falls_back_to_the_mtime_outside_a_repository
        with_repo(init: false) do
          write_file("a.md", "one")
          File.utime(LONG_AGO, LONG_AGO, "a.md")

          assert_equal LONG_AGO, LastModified.for("a.md")
        end
      end

      def test_for_falls_back_to_the_mtime_when_git_is_not_installed
        with_repo do |repo|
          write_file("a.md", "one")
          commit(repo, "add a", at: FIRST)
          File.utime(LONG_AGO, LONG_AGO, "a.md")

          with_path do
            assert_equal LONG_AGO, LastModified.for("a.md")
          end
        end
      end

      def test_for_raises_for_a_file_that_git_and_the_disk_both_lack
        with_repo do |repo|
          write_file("a.md", "one")
          commit(repo, "add a", at: FIRST)

          assert_raises(Errno::ENOENT) { LastModified.for("missing.md") }
        end
      end

      def test_for_sees_a_new_commit
        with_repo do |repo|
          write_file("a.md", "one")
          commit(repo, "add a", at: FIRST)

          assert_equal Time.utc(2021, 3, 1, 10), LastModified.for("a.md")

          write_file("a.md", "two")
          write_file("b.md", "one")
          commit(repo, "edit a, add b", at: SECOND)

          assert_equal Time.utc(2021, 4, 15, 18, 30), LastModified.for("a.md")
          assert_equal Time.utc(2021, 4, 15, 18, 30), LastModified.for("b.md")
        end
      end

      def test_for_reads_the_history_once_until_head_moves
        with_repo do |repo|
          write_file("a.md", "one")
          write_file("b.md", "one")
          commit(repo, "add both", at: FIRST)

          with_git_logged do |calls|
            LastModified.for("a.md")
            LastModified.for("b.md")
            LastModified.for("a.md")

            assert_equal 1, calls.call.count { |call| call.include?(" log ") }
          end

          write_file("b.md", "two")
          commit(repo, "edit b", at: SECOND)

          with_git_logged do |calls|
            assert_equal Time.utc(2021, 4, 15, 18, 30), LastModified.for("b.md")
            LastModified.for("a.md")

            assert_equal 1, calls.call.count { |call| call.include?(" log ") }
          end
        end
      end

      private

      # Runs the block in a scratch directory that is the working directory and,
      # unless +init+ is false, a git repository with no commits. Git ignores the
      # user's configuration and never looks above the scratch directory.
      def with_repo(init: true)
        Dir.mktmpdir("layer22-git") do |repo|
          with_env(GIT_ENV.merge("GIT_CEILING_DIRECTORIES" => File.dirname(repo))) do
            git(repo, "init", "-q") if init
            Dir.chdir(repo) { yield repo }
          end
        end
      end

      def with_env(vars)
        saved = vars.keys.to_h { |key| [key, ENV[key]] }
        vars.each { |key, value| ENV[key] = value }
        yield
      ensure
        saved.each { |key, value| ENV[key] = value }
      end

      # Puts a git on PATH that records its arguments before running the real one,
      # and yields a callable returning the recorded calls, one string per call.
      def with_git_logged
        real_git = IO.popen(["which", "git"], &:read).strip
        script = %(echo " $* " >> "${0%/*}/calls.log"\nexec #{real_git.shellescape} "$@")
        with_path("git" => script) do |bin|
          yield -> { File.readlines(File.join(bin, "calls.log"), chomp: true) }
        end
      end

      def commit(repo, message, at:, authored: at)
        git(repo, "add", "-A")
        git(repo, "commit", "-q", "-m", "#{name}: #{message}", env: {"GIT_AUTHOR_DATE" => authored, "GIT_COMMITTER_DATE" => at})
      end

      def git(repo, *args, env: {})
        identity = %w[-c user.name=Test -c user.email=test@example.test -c commit.gpgsign=false -c core.hooksPath=/dev/null]
        system(env, "git", *identity, *args, chdir: repo, out: File::NULL, err: File::NULL) || flunk("git #{args.join(" ")} failed")
      end
    end
  end
end
