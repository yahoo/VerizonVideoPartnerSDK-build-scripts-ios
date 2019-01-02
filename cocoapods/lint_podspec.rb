module Fastlane
  module Actions
    class LintPodspecAction < Action
      def self.run(params)
        require 'cocoapods'
        podspec = params[:podspec_path]
        sources_repo = params[:sources_repo]
        
        sh "bundle exec pod spec lint #{podspec} --sources=#{sources_repo} --fail-fast --allow-warnings --verbose"
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        'Lint podspec'
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :podspec_path,
                                       description: 'Podspec path + name',
                                       is_string: true,
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :sources_repo,
                                       description: 'Podspecs sources repo',
                                       is_string: true,
                                       optional: false)
        ]
      end

      def self.authors
        ['AndriiMoskvin/Berk0ld']
      end

      def self.is_supported?(_platform)
        true
      end
    end
  end
end
