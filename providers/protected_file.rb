include Azure::Cookbook

use_inline_resources if defined?(use_inline_resources)

def why_run_supported?
  true
end

action :create do
  do_protected_file(:create)
end

action :create_if_missing do
  do_protected_file(:create_if_missing)
end

action :delete do
  do_protected_file(:delete)
end

action :touch do
  do_protected_file(:touch)
end

def do_protected_file(resource_action)
  setup_storage_service
  require 'azure/blob/auth/shared_access_signature'

  sas = Azure::Blob::Auth::SharedAccessSignature.new
  parsed_remote_path = URI.parse(new_resource.remote_path)
  signed = sas.signed_uri(parsed_remote_path, {})
  signed_remote_path = signed.to_s

  remote_file new_resource.name do
    path new_resource.path
    source signed_remote_path
    owner new_resource.owner
    group new_resource.group
    mode new_resource.mode
    checksum new_resource.checksum
    backup new_resource.backup
    if node['platform_family'] == 'windows'
      inherits new_resource.inherits
      rights new_resource.rights
    end
    action resource_action
  end
end


