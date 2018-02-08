module Fastlane
  module Actions
    class UpdatePodspecAction < Action
      def self.run(params)
        require 'cocoapods'
        podspec = params[:podspec_path]
        version = params[:version]
        asset_url = params[:framewokr_link_url]

        podspec_contents = File.open(podspec, 'rb', &:read)
                               .gsub(/new_version/, version.to_s)
                               .gsub(/framework_zip_url/, asset_url.to_s)
        File.open(podspec, 'w') { |file| file.write(podspec_contents) }
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        'Updating podspec file with version and framework url link'
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :podspec_path,
                                       description: 'Podspec path + name',
                                       is_string: true,
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :version,
                                       description: 'Version value for podspec to be updated with',
                                       is_string: true,
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :framewokr_link_url,
                                       description: 'Web link/url to framework zip',
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
