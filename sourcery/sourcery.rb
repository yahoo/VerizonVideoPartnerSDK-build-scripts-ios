module Fastlane
  module Actions
    class SourceryAction < Action
      def self.run(params)
        action = params[:action]

        case action
        when "install"
            require 'brew'
            brew(command: 'install sourcery')
        else
          UI.user_error!("Not implemented!")
        end
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Install Sourcery via Homebrew if needed"
      end

      def self.details
        "
        - Install Sourcery via Homebrew
        "
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(
            key: :action,
            description: "List of possible actions",
            is_string: true,
            optional: false,
            verify_block: proc do |value|
              case value
              when "install"
                true
              else
                UI.user_error!("Don't support action: #{value}")
              end
            end)
        ]
      end

      def self.authors
        ["BogdanBilonog"]
      end
    end
  end
end
