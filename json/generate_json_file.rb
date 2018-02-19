module Fastlane
  module Actions
    class GenerateJsonFileAction < Action
      def self.run(params)
        destination = params[:destination]
        File.open(destination, 'w') do |file|
          require 'json'
          json = params[:json]

          file.write(json.to_json)
        end
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        'Writes provided json to destination file'
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :json,
                                       description: 'JSON compatible hash',
                                       is_string: false,
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :destination,
                                       description: 'Destination for json file',
                                       optional: false,
                                       verify_block: proc do |value|
                                         # add verification logic here
                                       end)
        ]
      end

      def self.authors
        ['AndriiMoskvin']
      end

      def self.is_supported?(_platform)
        true
      end
    end
  end
end
