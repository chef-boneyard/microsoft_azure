actions :set

attribute :uninstall_chef_client, kind_of: [TrueClass, FalseClass], default: false
attribute :delete_chef_config, kind_of: [TrueClass, FalseClass], default: false

default_action :set