module Fastlane
  module Actions
    class GithubChangelogGeneratorAction < Action
      def self.run(params)
        require 'github_changelog_generator'
        output_file_path = params[:output]

        action = 'github_changelog_generator'
        action << " --token #{params[:token]}"
        action << " --output #{output_file_path}"
        action << ' --unreleased-only' if params[:unreleased_only] == true
        action << ' --no-issues'
        action << ' --no-compare-link'

        sh action
        contents = File.open(output_file_path, 'rb', &:read)
        result = contents[/\*{2}.*\)\)/m, 0]

        if !result.nil?
          UI.important result
          result
        else
          result = 'Zero merged pull requests! Work harder!'
          UI.important result
        end

        File.delete(output_file_path)
        result
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        'Generate github changelog!'
      end

      def self.details
        'Details available here: https://github.com/skywinder/github-changelog-generatorYou can use this action to do cool things...'
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :token,
                                       env_name: 'GITHUB_CHANGELOG_TOKEN',
                                       description: 'GITHUB_CHANGELOG_TOKEN for Github ChangeLog Generator', #
                                       verify_block: proc do |value|
                                         UI.user_error!('No GITHUB_API_TOKEN for Github ChangeLog Generator') unless value && !value.empty?
                                       end),
          FastlaneCore::ConfigItem.new(key: :output,
                                       description: 'Output file path + name for changelog',
                                       is_string: true,
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :unreleased_only,
                                       description: 'Unreleased Changelog only or not',
                                       is_string: false,
                                       default_value: false)
        ]
      end

      def self.return_value
        'String with a changelog text.'
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
