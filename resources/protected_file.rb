actions :create, :create_if_missing, :touch, :delete

default_action :create_if_missing

attribute :path, kind_of: String, name_attribute: true
attribute :remote_path, kind_of: String
attribute :storage_account, required: true
attribute :access_key, required: true
attribute :owner, regex: Chef::Config[:user_valid_regex]
attribute :group, regex: Chef::Config[:group_valid_regex]
attribute :mode, kind_of: [String, NilClass], default: nil
attribute :checksum, kind_of: [String, NilClass], default: nil
attribute :backup, kind_of: [Integer, FalseClass], default:5
if node['platform_family'] == 'windows'
  attribute :inherits, kind_of: [TrueClass, FalseClass], default: true
  attribute :rights, kind_of: Hash, default: nil
end
