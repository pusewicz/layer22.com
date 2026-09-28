# frozen_string_literal: true

require "yaml"

module Layer22
  module Content
    # Loads the YAML files in _data/, keyed by file name, like Jekyll's site.data.
    module DataFiles
      # Returns {"resume" => {...}, ...} for every .yml file in +dir+.
      def self.load_all(dir = "_data")
        Dir.glob("#{dir}/*.{yml,yaml}").sort.to_h do |path|
          [File.basename(path, ".*"), YAML.safe_load_file(path, permitted_classes: [Date, Time])]
        end
      end
    end
  end
end
