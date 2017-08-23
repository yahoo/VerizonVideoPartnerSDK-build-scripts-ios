module Fastlane
  module Actions
    class SdkVersionStringAction < Action
      def self.run(params)
        version = params[:version]
        sh "git fetch --unshallow || git fetch"
        patch = sh("git rev-list --count origin/#{Actions::GitBranchAction.run({})}")
        "#{version}.#{patch}"
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Returns SDK version in format - 1.100"
      end

      def self.details
        "SDK version is calculated based on passed major version and number of commits in current git branch"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :version,
                                       description: "Major version of SDK",
                                       is_string: true,
                                       optional: false)
        ]
      end

      def self.return_value
        "String value of SDK version"
      end

      def self.authors
        ["AndriiMoskvin/Berk0ld"]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
