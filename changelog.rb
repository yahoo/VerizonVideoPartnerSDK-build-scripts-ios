desc "Creates change log with unreleased PRs only"
lane :unreleased_description do |options|
  token = options[:api_token]
  UI.message("Generating description...")
  tmp_file = "unreleased.md"
  sh "gem list -i github_changelog_generator || sudo gem install --no-ri --no-rdoc github_changelog_generator"
  sh "github_changelog_generator --token #{api_token} --output #{tmp_file} --unreleased-only"
  contents = File.open(tmp_file, 'rb') { |f| f.read }
  File.delete(tmp_file)

  result = contents[/\*{2}.*\)\)/m, 0]
  if result != nil
    UI.message(result)
    result
  else
    "Zero merged pull requests! Work harder!"
  end
end
