module Fastlane
  module Actions
    class UtilsAction < Action
      def self.run(params)
        action = params[:action]

        case action
        when "is_branch_up_to_date"
            sh "git fetch"
            current = sh("git rev-parse HEAD")
            origin = sh("git rev-parse origin/#{git_branch}")
            if current != origin
              UI.important("Outdated version of #{git_branch}. Skipping release!")
              return false
            end
            true
        else
          UI.user_error!("Not implemented!")
        end
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Utils actions"
      end

      def self.details
        "
        - Check is current branch is up to date 
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
              when "is_branch_up_to_date"
                true
              else
                UI.user_error!("Don't support action: #{value}")
              end
            end
          )
        ]
      end

      def self.authors
        ["BogdanBilonog"]
      end
    end
  end
end
