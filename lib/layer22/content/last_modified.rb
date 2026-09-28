# frozen_string_literal: true

module Layer22
  module Content
    # Finds when a source file last changed, like the jekyll-last-modified-at
    # plugin: the time of the last commit that touched it, or its mtime when git
    # has no answer. One `git log` pass covers every file and is reused until
    # HEAD moves.
    module LastModified
      # Returns the last-modified Time of the file at +path+, relative to the repository root.
      def self.for(path)
        commit_times[path] || File.mtime(path)
      end

      def self.commit_times
        head = git("rev-parse", "HEAD")&.strip
        return {} unless head

        @commit_times = nil unless @head == head
        @head = head
        @commit_times ||= parse_log(git("-c", "core.quotePath=false", "log", "--format=%x00%ct", "--name-only") || "")
      end

      # Maps each path in `git log --format=%x00%ct --name-only` output to the
      # time of the newest commit that lists it.
      def self.parse_log(log)
        log.split("\0").drop(1).each_with_object({}) do |commit, times|
          timestamp, *paths = commit.lines(chomp: true).reject(&:empty?)
          paths.each { |path| times[path] ||= Time.at(Integer(timestamp)) }
        end
      end

      def self.git(*args)
        output = IO.popen(["git", *args], err: File::NULL, &:read)
        output if $?.success?
      rescue Errno::ENOENT
        nil
      end

      private_class_method :commit_times, :parse_log, :git
    end
  end
end
