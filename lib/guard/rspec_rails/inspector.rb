module Guard
  class RSpecRails

    # The inspector verifies if the changed paths are valid
    # for Guard::RSpectacular.
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

          clear

          paths
        end

        private

        # Clears the list of RSpec specs in this project.
        #
        def clear
          @rspec_specs = nil
        end

        # Tests if the file is valid.
        #
        # @param [String] file the file
        # @return [Boolean] when the file valid
        #
        def rspec_spec?(path)
          rspec_specs.include?(path)
        end

        # Scans the project and keeps a list of all
        # files ending with `_spec.rb` within the `spec`
        # directory.
        #
        # @return [Array<String>] the valid files
        #
        def rspec_specs
          @rspec_specs ||= Dir.glob('spec/**/*_spec.rb')
        end

      end
    end
  end
end
