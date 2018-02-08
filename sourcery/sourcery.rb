module Fastlane
  module Actions
    class SourceryAction < Action
      def self.run(params)
        action = params[:action]

        case action
        when 'install'
          require 'brew'
          brew(command: 'install sourcery')
        when 'run'
          sources = params[:sources]
          templates = params[:templates]
          output = params[:output]

          sh "sourcery --sources #{sources} --templates #{templates} --output #{output}"
        else
          UI.user_error!('Not implemented!')
        end
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        'Work with Sourcery'
      end

      def self.details
        "
        - Install Sourcery via Homebrew
        - Run Sourcery
        "
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(
            key: :action,
            description: 'List of possible actions',
            is_string: true,
            optional: false,
            verify_block: proc do |value|
              case value
              when 'install'
                true
              when 'run'
                true
              else
                UI.user_error!("Don't support action: #{value}")
              end
            end
          ),
          FastlaneCore::ConfigItem.new(
            key: :sources,
            description: 'Path to source folder for Sourcery',
            is_string: true,
            optional: true
          ),
          FastlaneCore::ConfigItem.new(
            key: :templates,
            description: 'Path to template folder for Sourcery',
            is_string: true,
            optional: true
          ),
          FastlaneCore::ConfigItem.new(
            key: :output,
            description: 'Path to output folder/file for Sourcery',
            is_string: true,
            optional: true
          )
        ]
      end

      def self.authors
        ['BogdanBilonog']
      end
    end
  end
end
