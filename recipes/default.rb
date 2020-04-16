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

# install any needed dependency for nokogiri

chef_gem 'azure' do
  version node['microsoft_azure']['azure_gem_version']
  action :install
  compile_time true
end

chef_gem 'azure_mgmt_compute' do
  version node['microsoft_azure']['arm_compute_gem_version']
  action :install
  compile_time true
end

require 'azure'
require 'azure_mgmt_compute'
