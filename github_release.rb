fastlane_require 'excon'
require 'excon'

fastlane_require 'json'
require 'json'

GITHUB_API_SERVER_URL = "https://api.github.com"

def headers()
  require 'base64'
  headers = Hash.new
  headers['User-Agent'] = 'onemobilesdk_github_release'
  api_token = ENV["GITHUB_API_TOKEN"]
  headers['Authorization'] = "Basic #{Base64.strict_encode64(api_token)}" unless api_token == nil
  headers
end

desc "Upload assets to Github Release"
lane :upload_assets do |options|
  url_template = options[:upload_url]
  assets = options[:assets]

  result = Array.new
  assets.each do |asset|
    absolute_path = File.absolute_path(asset)
    UI.user_error!("Asset #{absolute_path} doesn't exist") unless File.exist?(absolute_path)

    result << upload_file(absolute_path, url_template, api_token)
  end

  result
end

def upload_file(file, url_template)
  require 'addressable/template'
  name = File.basename(file)
  UI.important("Uploading file '#{name}'...")
  expanded_url = Addressable::Template.new(url_template).expand(name: name).to_s
  headers = headers()
  headers['Content-Type'] = 'application/zip'

  response = Excon.post(expanded_url, headers: headers, body: File.read(file))

  case response.status
  when 201
    UI.success("Successfully uploaded '#{name}'.")
    return JSON.parse(response.body)
  else
    UI.error("GitHub responded with #{response.status}:#{response.body}")
    UI.user_error!("Failed to upload asset #{name} to GitHub.")
  end
  nil
end

desc "Update existing GitHub Release"
lane :update_github_release do |options|
  repo_name = options[:repo_name]
  tag_name = options[:tag_name]
  is_draft = options[:is_draft]
  is_prerelease = options[:is_prerelease]
  description = options[:description]
  release_id = options[:release_id]

  body_obj = {
    'tag_name' => tag_name,
    'draft' => is_draft,
    'prerelease' => is_prerelease
  }
  body_obj['body'] = description if description != nil
  body = body_obj.to_json

  url = "#{GITHUB_API_SERVER_URL}/repos/#{repo_name}/releases/#{release_id}"
  response = Excon.patch(url, headers: headers(), body: body)

  case response.status
  when 201
    UI.success("Successfully updated release at tag \"#{options[:tag_name]}\" on GitHub")
  when 404
    UI.error(response.body)
    UI.user_error!("Repository #{repo_name} cannot be found, please double check its name and that you provided a valid API token (GITHUB_API_TOKEN)")
  when 401
    UI.error(response.body)
    UI.user_error!("You are not authorized to access #{repo_name}, please make sure you provided a valid API token (GITHUB_API_TOKEN)")
  else
    if response.status != 200
      UI.error("GitHub responded with #{response.status}:#{response.body}")
    end
  end
  JSON.parse(response.body)
end

def handleResponse(response, repo_name)
  case response.status
  when 404
    UI.error(response.body)
    UI.user_error!("Repository #{repo_name} cannot be found, please double check its name and that you provided a valid API token (GITHUB_API_TOKEN)")
    return nil
  when 401
    UI.error(response.body)
    UI.user_error!("You are not authorized to access #{repo_name}, please make sure you provided a valid API token (GITHUB_API_TOKEN)")
    return nil
  else
    if response.status != 200
      UI.error("GitHub responded with #{response.status}:#{response.body}")
      return nil
    end
  end

  UI.message("Successfully got releases for #{repo_name}!")
  JSON.parse(response.body)
end

desc "Get all GitHub Releases for repo"
lane :get_github_releases do |options|
  repo_name = options[:repo_name]

  url = "#{GITHUB_API_SERVER_URL}/repos/#{repo_name}/releases"
  response = Excon.get(url, headers: headers())

  handleResponse(response, repo_name)
end

lane :get_latest_release do |options|
  repo_name = options[:repo_name]

  url = "#{GITHUB_API_SERVER_URL}/repos/#{repo_name}/releases/latest"
  response = Excon.get(url, headers: headers())

  handleResponse(response, repo_name)
end

desc "Get all assets for GitHub Releases"
lane :get_assets_list do |options|
  repo_name = options[:repo_name]
  release_id = options[:release_id]

  url = "#{GITHUB_API_SERVER_URL}/repos/#{repo_name}/releases/#{release_id}/assets"
  response = Excon.get(url, headers: headers())

  handleResponse(response, repo_name)
end

desc "Delete asset for GitHub Release"
lane :delete_asset do |options|
  repo_name = options[:repo_name]
  asset_id = options[:asset_id]

  url = "#{GITHUB_API_SERVER_URL}/repos/#{repo_name}/releases/assets/#{asset_id}"
  response = Excon.delete(url, headers: headers())
  case response.status
  when 204
    UI.success("Successfully deleted #{asset_id}!")
  else
    if response.status != 204
      UI.error("GitHub responded with #{response.status}:#{response.body}")
    end
  end
end

lane :get_release_by_tag do |options|
  version = options[:tag]
  repo_name = options[:repo_name]

  draft_release = nil
  releases = get_github_releases(repo_name: repo_name)
  releases.each do |current|
    next unless current['tag_name'] == version

    UI.message("Found release #{current["name"]}!")
    draft_release = current
  end
  draft_release
end

lane :publish_release do |options|
  release_version = options[:release_version]
  repo_name = options[:repo_name]

  release = get_release_by_tag(
    tag: release_version,
    repo_name: repo_name)

  UI.user_error!("Release not found for tag #{version}") if release == nil

  update_github_release(
    tag_name: release_version,
    release_id: release["id"],
    is_draft: false,
    is_prerelease: false,
    repo_name: repo_name)
end
