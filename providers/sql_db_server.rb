# Author Jeff Mendoza (jemendoz@microsoft.com)
#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#--------------------------------------------------------------------------

include Azure::Cookbook

action :create do
  mc = setup_management_service

  sms = Azure::SqlDatabaseManagementService.new
  
  locs = []
  sms.list_servers.each { |srv| locs.push(srv.location) }
  
  if locs.include?(new_resource.location)
    Chef::Log.debug("DB in  #{new_resource.location} already exists.")
    sms.list_servers.each do |srv|
      if srv.location == new_resource.location
        @new_resource.server_name(srv.name)
      end
    end
  else
    Chef::Log.debug("Creating DB in #{new_resource.location}.")
    server = sms.create_server(new_resource.login, new_resource.password, new_resource.location)
    @new_resource.server_name(server.name)
    Chef::Log.debug("Created DB #{server.name}.")
    sms.set_sql_server_firewall_rule(server.name, 'chef-node')
  end
  mc.unlink
end
