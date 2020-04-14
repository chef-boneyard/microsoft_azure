# Author:: Jeff Mendoza (jemendoz@microsoft.com)
#-------------------------------------------------------------------------
# Copyright:: (c) Microsoft Open Technologies, Inc.
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

  sms = Azure::StorageManagementService.new

  if sms.get_storage_account(new_resource.name)
    Chef::Log.debug("Storage account #{new_resource.name} already exists.")
  else

    if new_resource.location.nil? && new_resource.affinity_group_name.nil?
      raise 'Must provide either location or affinity group.'
    end

    # otherwise create
    sa_opts = { location: new_resource.location,
      affinity_group_name: new_resource.affinity_group_name,
      geo_replication_enabled: new_resource.geo_replication_enabled }
    Chef::Log.debug("Creating storage account #{new_resource.name}.")
    sms.create_storage_account(new_resource.name, sa_opts)
  end
  mc.unlink
end

action :delete do
  mc = setup_management_service

  sms = Azure::StorageManagementService.new

  if sms.get_storage_account(new_resource.name)

    # otherwise delete
    Chef::Log.debug("Deleting storage account #{new_resource.name}.")
    sms.delete_storage_account(new_resource.name)
  else
    Chef::Log.debug("Storage account #{new_resource.name} already deleted.")
  end
  mc.unlink
end
