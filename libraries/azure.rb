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

module Azure
  module Cookbook

    def setup_management_service
      begin
        require 'azure'
      rescue LoadError
        Chef::Log.error("Missing gem 'azure'. Use the default azure recipe to install it first.")
      end
      mc = Tempfile.new(['mc', '.pem'])
      mc.chmod(0600)
      mc.write(new_resource.management_certificate)
      mc.close
      Azure.configure do |config|
        config.management_certificate = mc.path
        config.subscription_id        = new_resource.subscription_id
        config.management_endpoint    = new_resource.management_endpoint
      end
      mc
    end

    def setup_storage_service
      begin
        require 'azure'
      rescue LoadError
        Chef::Log.error("Missing gem 'azure'. Use the default azure recipe to install it first.")
      end
      Azure.configure do |config|
        config.storage_account_name = new_resource.storage_account
        config.storage_access_key   = new_resource.access_key
      end
    end
    
  end
end
