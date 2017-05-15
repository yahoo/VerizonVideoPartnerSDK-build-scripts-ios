desc "Update template podspec with version and asset_url."
lane :update_podspec do |options|
  asset_url = options[:asset_url]
  raise "Expecting asset_url!" unless asset_url != nil
  version = options[:version]
  raise "Expecting version!" unless version != nil
  podspec = options[:podspec]
  raise "Expecting podspec!" unless podspec != nil

  UI.important("Updating #{podspec} with version #{version} and #{asset_url}.")

  podspec_contents =
    File.open(podspec, 'rb') { |file| file.read }
    .gsub(/new_version/, "#{version}")
    .gsub(/framework_zip_url/, "#{asset_url}")
  File.open(podspec, 'w') { |file| file.write(podspec_contents) }
end

desc "Deploy podspec to the podspec repository."
lane :deploy_podspec do |options|
  spec_repo_name = options[:spec_repo_name]
  raise "Expecting spec_repo_name!" unless spec_repo_name != nil
  spec_repo_url = options[:spec_repo_url]
  raise "Expecting spec_repo_url!" unless spec_repo_url != nil
  podspec = options[:podspec]
  raise "Expecting podspec!" unless podspec != nil

  sh "gem list -i pod || sudo gem install --no-ri --no-rdoc cocoapods"
  sh "pod repo add #{spec_repo_name} #{spec_repo_url}" unless sh("pod repo list").include? spec_repo_name
  sh "pod repo push #{spec_repo_name} #{podspec}"
end
