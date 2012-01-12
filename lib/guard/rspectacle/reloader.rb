module Guard
  class RSpectacle

    # The reloader class handles reloading of changed
    # files.
    #
    class Reloader
      class << self

        # Reloads the given file.
        #
        # @param [String] file the changed file
        # @return [Boolean] the load status
        # @raise [:task_has_failed] when run_on_change has failed
        #
        def reload_file(file)
          return false unless file =~ /\.rb$/

          if File.exists?(file)
            Formatter.info "Reload #{ file }"
            load file

          else
            false
          end

        rescue Exception => e
          Formatter.error "Error reloading file #{ file }: #{ e.message }"

          throw :task_has_failed
        end

      end
    end
  end
end
