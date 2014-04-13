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

# FIXME must force macaddr version to workaround systemu conflict
chef_gem 'macaddr' do
  action :remove
  not_if '/opt/chef/embedded/bin/gem list macaddr | grep "(1.6.1)"'
end
chef_gem 'macaddr' do
  version '1.6.1'
  action :install
end
 

chef_gem 'azure' do
  version '0.6.0' #FIXME systemu gem conflict workaround
  #version node['microsoft_azure']['azure_gem_version']
  action :install
end

require 'azure'
