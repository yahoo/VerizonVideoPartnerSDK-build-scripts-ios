module Fastlane
  module Actions
    class SourceryAction < Action
      def self.run(params)
        command = '
            # Exit immediately if a command exits with a non-zero status
            set -e

            # If Sourcery installed, exit with success code
            if which sourcery > /dev/null; then
                exit 0
            fi

            # If Homebrew missed, exit with error code
            if ! which brew > /dev/null; then
                exit 1
            fi

            # Install Sourcery with Homebrew
            brew install sourcery
        '
        # If command errored, generate Fastlane error
        unless system(command)
           UI.user_error!('Homebrew is missing. Please visit https://brew.sh and install brew.')
        end
      end
    end
  end
end
