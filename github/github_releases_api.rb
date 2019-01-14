module Fastlane
  module Actions
    class GithubReleasesApiAction < Action
      def self.run(params)
        require 'excon'
        require 'json'
        require 'base64'

        action = params[:action]
        UI.important action
        repo_name = params[:repo_name]
        github_api_server_url = params[:github_api_server_url]
        headers = headers(params)

        base_url = "#{github_api_server_url}/repos/#{repo_name}/releases"
        case action
        when 'get_github_releases'
          tag = params[:tag]
          response = Excon.get(base_url, headers: headers)
          releases = handle_response(response, repo_name)

          if tag.nil?
            return releases
          else
            tagged_release = nil
            releases.each do |current|
              next unless current['tag_name'] == tag

              tagged_release = current
            end
            return tagged_release
          end

        when 'get_latest_github_release'
          response = Excon.get(base_url << '/latest', headers: headers)
          return handle_response(response, repo_name)

        when 'get_assets_list_of_release'
          release_id = params[:release_id]
          response = Excon.get(base_url << "/#{release_id}/assets", headers: headers)
          return handle_response(response, repo_name)

        when 'delete_asset_in_release'
          asset_id = params[:asset_id]
          response = Excon.delete(base_url << "/assets/#{asset_id}", headers: headers)
          case response.status
          when 204
            UI.success("Successfully deleted #{asset_id}!")
          else
            UI.user_error!("GitHub responded with #{response.status}:#{response.body}")
          end

        when 'update_github_release'
          is_draft = params[:is_draft]
          is_prerelease = params[:is_prerelease]
          description = params[:description]
          release_id = params[:release_id]
          tag = params[:tag]

          if is_draft.nil? || is_prerelease.nil? || release_id.nil? || tag.nil?
            UI.user_error!('Missing required parameter!')
          end

          body_obj = {
            'tag_name' => tag,
            'draft' => is_draft,
            'prerelease' => is_prerelease
          }
          body_obj['body'] = description unless description.nil?
          body = body_obj.to_json

          response = Excon.patch(base_url << "/#{release_id}", headers: headers, body: body)
          return handle_response(response, repo_name)

        when 'upload_assets_to_github_release'
          url_template = params[:upload_url_template]
          assets = params[:assets]

          result = []
          assets.each do |asset|
            absolute_path = File.absolute_path(asset)
            UI.user_error!("Asset #{absolute_path} doesn't exist") unless File.exist?(absolute_path)

            result << upload_file(absolute_path, url_template, headers)
          end
          return result

        when 'is_release_exist'
          params[:action] = 'get_github_releases'
          release = run(params)
          return !release.nil?

        when 'delete_latest_prerelease'
          releases_response = Excon.get(base_url, headers: headers)
          UI.important 'Unable to get releases!' if releases_response.status != 200

          releases = JSON.parse releases_response.body
          tag = params[:tag]
          latest_release = releases.select { |release| release['tag_name'] == tag }.first

          if latest_release.nil?
            UI.success 'No release to delete! Skipping!'
          else
            UI.user_error! 'Not a prerelease!' if latest_release['prerelease'] == false

            release_id = latest_release['id']
            UI.important latest_release['name'].to_s

            delete_tag_response = Excon.delete("#{github_api_server_url}/repos/#{repo_name}/git/refs/tags/#{tag}", headers: headers)
            UI.important "No tag to delete - #{tag}" if delete_tag_response.status != 204

            delete_release_response = Excon.delete(base_url + "/#{release_id}", headers: headers)
            UI.important 'No GitHub release to delete!' if delete_release_response.status != 204
          end

        else
          UI.user_error!('Not implemented!')
        end
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        'GitHub Releases API communication action'
      end

      def self.details
        "
        - Get GitHub Releases\
        - Update GitHub Release\
        - Upload asset to GitHub Release\
        - Delete asset from GitHub Release\
        - Get list of assets for GitHub Release\
        - Check GitHub release existence\
        - Delete GitHub release and tag\
        "
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(
            key: :action,
            description: 'List of possible actions',
            is_string: true,
            optional: false,
            verify_block: proc do |value|
              case value
              when 'get_github_releases'
                true
              when 'get_latest_github_release'
                true
              when 'get_assets_list_of_release'
                true
              when 'delete_asset_in_release'
                true
              when 'upload_assets_to_github_release'
                true
              when 'update_github_release'
                true
              when 'is_release_exist'
                true
              when 'delete_latest_prerelease'
                true
              else
                UI.user_error!("Don't support action: #{value}")
              end
            end
          ),
          FastlaneCore::ConfigItem.new(
            key: :github_api_server_url,
            description: 'GitHub Releases API server url',
            default_value: 'https://api.github.com',
            is_string: true,
            optional: false
          ),
          FastlaneCore::ConfigItem.new(
            key: :user_agent,
            description: 'Custom User-Agent header',
            is_string: true,
            optional: false,
            default_value: 'VerizonVideoPartnerSDK_github_release'
          ),
          FastlaneCore::ConfigItem.new(
            key: :token,
            description: 'GitHub Releases API token (could be set in GITHUB_API_TOKEN environment variable)',
            is_string: true,
            optional: false,
            default_value: ENV['GITHUB_API_TOKEN']
          ),
          FastlaneCore::ConfigItem.new(
            key: :repo_name,
            description: 'GitHub Repository name (f.e. `VerizonAdPlatforms/VerizonVideoPartnerSDK-releases-iOS`)',
            is_string: true,
            optional: false,
            default_value: 'VerizonAdPlatforms/VerizonVideoPartnerSDK-releases-iOS'
          ),
          FastlaneCore::ConfigItem.new(
            key: :release_id,
            description: 'GitHub Release identifier',
            is_string: true,
            optional: true
          ),
          FastlaneCore::ConfigItem.new(
            key: :asset_id,
            description: 'GitHub Release Asset identifier',
            is_string: true,
            optional: true
          ),
          FastlaneCore::ConfigItem.new(
            key: :tag,
            description: 'GitHub Releases Tag',
            is_string: true,
            optional: true
          ),
          FastlaneCore::ConfigItem.new(
            key: :is_draft,
            description: 'GitHub Release is draft or not',
            is_string: false,
            optional: true
          ),
          FastlaneCore::ConfigItem.new(
            key: :is_prerelease,
            description: 'GitHub Release is prerelease or release',
            is_string: false,
            optional: true
          ),
          FastlaneCore::ConfigItem.new(
            key: :description,
            description: 'GitHub Release description',
            optional: true,
            is_string: true
          ),
          FastlaneCore::ConfigItem.new(
            key: :upload_url_template,
            description: 'Upload url template for an asset',
            optional: true,
            is_string: true
          ),
          FastlaneCore::ConfigItem.new(
            key: :assets,
            description: 'An array of pathes to assets for uploading to GitHub Release',
            optional: true,
            is_string: false
          ),
          FastlaneCore::ConfigItem.new(
            key: :version,
            description: 'Version of GitHub release',
            optional: true,
            is_string: true
          )
        ]
      end

      def self.return_value
        'Depends on the action called.'
      end

      def self.authors
        ['AndriiMoskvin/Berk0ld']
      end

      def self.is_supported?(_platform)
        true
      end

      def self.headers(params)
        headers = {}
        headers['User-Agent'] = params[:user_agent]
        headers['Authorization'] = "Basic #{Base64.strict_encode64(params[:token])}"
        headers
      end
      private_class_method :headers

      def self.handle_response(response, repo_name)
        case response.status
        when 404
          UI.error(response.body)
          UI.user_error!("Repository #{repo_name} cannot be found, please double check its name and that you provided a valid API token (GITHUB_API_TOKEN)")
          nil
        when 401
          UI.error(response.body)
          UI.user_error!("You are not authorized to access #{repo_name}, please make sure you provided a valid API token (GITHUB_API_TOKEN)")
          nil
        else
          if response.status == 200 || response.status == 201
            JSON.parse(response.body)
          else
            UI.user_error!("GitHub responded with #{response.status}:#{response.body}")
          end
        end
      end
      private_class_method :handle_response

      def self.upload_file(filePath, url_template, headers)
        require 'addressable/template'
        filename = File.basename(filePath)
        UI.important("Uploading file '#{filename}'...")
        expanded_url = Addressable::Template.new(url_template).expand(name: filename).to_s
        headers['Content-Type'] = 'application/zip'
        response = Excon.post(expanded_url, headers: headers, body: File.read(filePath))
        case response.status
        when 201
          UI.success("Successfully uploaded '#{filename}'.")
          return JSON.parse(response.body)
        else
          UI.error("GitHub responded with #{response.status}:#{response.body}")
          UI.user_error!("Failed to upload asset #{filename} to GitHub.")
          return nil
        end
      end
      private_class_method :upload_file
    end
  end
end
