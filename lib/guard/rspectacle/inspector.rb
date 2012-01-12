module Guard
  class RSpectacle

    # The inspector verifies if the changed paths are valid
    # for Guard::RSpectacle.
    #
    module Inspector
      class << self

        # Clean the changed paths and return only valid
        # RSpec specs.
        #
        # @param [Array<String>] paths the changed paths
        # @return [Array<String>] the valid spec files
        #
        def clean(paths)
          paths.uniq!
          paths.compact!

          if paths.include?('spec')
            paths = ['spec']
          else
            paths = paths.select { |p| rspec_spec?(p) }
          end

          paths
        end

        private

        # Tests if the file is valid.
        #
        # @param [String] file the file
        # @return [Boolean] when the file valid
        #
        def rspec_spec?(path)
          path =~ /_spec\.rb$/ && File.exists?(path)
        end

      end
    end
  end
end
