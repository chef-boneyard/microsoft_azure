# helper for retrieving a secret from an azure keyvault
include Azure::Cookbook

module Azure
  module KeyVault
    class KeyVaultClient
      def initialize(vault_endpoint = nil, authentication_endpoint = nil, token_audience = nil, api_version = nil)
        @vault_endpoint = vault_endpoint || 'vault.azure.net'
        @authentication_endpoint = authentication_endpoint || 'https://login.windows.net/'
        @token_audience = token_audience
        @api_version = api_version || '2016-10-01'

        if @token_audience.nil? && !@vault_endpoint.nil? then
          @token_audience = "https://#{@vault_endpoint}"
          Chef::Log.debug("Implicitly set token audience url to url=#{@token_audience}")
        end
      end

      def get_secret(vault_name, secret_name, spn = {}, version = nil)
        request_url = vault_request_url(vault_name, secret_name, version)
        token_provider = create_token_provider(spn)
        
        begin
          authorization_header = token_provider.get_authentication_header()
        rescue
          authorization_header = ''
        end
  
        headers = {'Authorization' => authorization_header}
        Chef::Log.debug("url = #{request_url} headers = #{headers}")
        begin
          http_client = Chef::HTTP.new(request_url, headers)
          response = http_client.get(http_client.url, headers)
          return JSON.parse(response)['value']
        rescue
          return nil
        end
      end

      def vault_request_url(vault_name, secret_name, version, resource = 'secrets')
        base_url = "https://#{vault_name}.#{@vault_endpoint}/#{resource}/#{secret_name}"
        base_url << "/#{version}" unless version.nil?
        base_url << "?api-version=#{@api_version}"
        Chef::Log.debug("Generated vault url: #{base_url}")
        return base_url
      end

      def create_token_provider(spn)
        Azure::KeyVault::validate_service_principal!(spn)
        tenant_id = spn['tenant_id']
        client_id = spn['client_id']
        secret = spn['secret']
        Azure::KeyVault::create_token_provider_impl_(tenant_id, client_id, secret, get_token_audience())
      end
  
      def get_token_audience()
        return Azure::KeyVault::get_token_audience_impl_(@authentication_endpoint, @token_audience)
      end
    end

    def self.create_token_provider_impl_(tenant_id, client_id, secret, token_audience)
      return MsRestAzure::ApplicationTokenProvider.new(tenant_id, client_id, secret, token_audience)
    end

    def self.get_token_audience_impl_(authentication_endpoint, token_audience)
      setup_arm_compute
      return MsRestAzure::ActiveDirectoryServiceSettings.new.tap do |s|
        s.authentication_endpoint = authentication_endpoint
        s.token_audience = token_audience

        Chef::Log.debug("auth endpoint = #{s.authentication_endpoint}")
        Chef::Log.debug("token audience = #{s.token_audience}")
      end
    end

    def self.validate_service_principal!(spn)
      spn['tenant_id'] ||= ENV['AZURE_TENANT_ID']
      spn['client_id'] ||= ENV['AZURE_CLIENT_ID']
      spn['secret'] ||= ENV['AZURE_CLIENT_SECRET']
      fail 'Invalid SPN info provided' unless spn['tenant_id'] && spn['client_id'] && spn['secret']
    end
  end
end

Chef::Recipe.send(:include, Azure::KeyVault)
Chef::Resource.send(:include, Azure::KeyVault)