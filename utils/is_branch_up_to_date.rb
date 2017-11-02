module Fastlane
  module Actions
    class IsBranchUpToDateAction < Action
      def self.run(params)
        git_branch = params[:git_branch]
        sh "git fetch"
        current = sh("git rev-parse HEAD")
        origin = sh("git rev-parse origin/#{git_branch}")
        if current != origin
          UI.important("Outdated version of #{git_branch}. Skipping release!")
          return false
        end
        true
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Check is given git branch is up to date"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(
            key: :git_branch,
            description: "Git branch",
            is_string: true,
            optional: true
          )
        ]
      end

      def self.authors
        ["BogdanBilonog"]
      end
    end
  end
end
