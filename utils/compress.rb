module Fastlane
  module Actions
    class CompressAction < Action
      def self.run(params)
        input = params[:input]
        output = params[:output]

        UI.message "Input: #{input}"
        UI.message "Output: #{output}"
        
        sh "ditto -c -k --sequesterRsrc --keepParent #{input} #{output}"
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        'Compress similar to the Finder \"Compress ...\"'
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :output,
                                       description: 'Output archive name',
                                       is_string: true,
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :input,
                                       description: 'Input folder to archive',
                                       is_string: true,
                                       optional: false)
        ]
      end

      def self.authors
        ['AndriiMoskvin']
      end

      def self.is_supported?(platform)
        platform == :ios
      end
    end
  end
end
