module Fastlane
  module Actions
    class UpdatePodspecAction < Action
      def self.run(params)
        podspec = params[:podspec_path]
        version = params[:version]
        asset_url = params[:framewokr_link_url]
        UI.message "Parameter API Token: #{podspec}"

        podspec_contents = File.open(podspec, 'rb') { |file| file.read }
          .gsub(/new_version/, "#{version}")
          .gsub(/framework_zip_url/, "#{asset_url}")
        File.open(podspec, 'w') { |file| file.write(podspec_contents) }
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Updating podspec file with version and framework url link"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :podspec_path,
                                       description: "Podspec path + name",
                                       is_string: true,
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :version,
                                       description: "Version value for podspec to be updated with.",
                                       is_string: true,
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :framewokr_link_url,
                                       description: "Web link/url to framework zip",
                                       is_string: true,
                                       optional: false)
        ]
      end

      def self.return_value
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
