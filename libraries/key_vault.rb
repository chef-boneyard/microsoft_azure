# helper for retrieving a secret from an azure keyvault
module Azure
  module KeyVault
    include Azure::Cookbook

    def vault_secret(vault, secret_name, spn = {}, version = nil)
      request_url = vault_request_url(vault, secret_name, version)
      token_provider = create_token_provider(spn)
      headers = {
        'Authorization' => token_provider.get_authentication_header,
      }
      http_client = Chef::HTTP.new(request_url, headers)
      response = http_client.get(http_client.url, headers)
      JSON.parse(response)['value']
    end

    private

    def token_audience
      setup_arm_compute
      @audience ||= MsRestAzure::ActiveDirectoryServiceSettings.new.tap do |s|
        s.authentication_endpoint = 'https://login.windows.net/'
        s.token_audience = 'https://vault.azure.net'
      end
    end

    def create_token_provider(spn)
      validate_service_principal!(spn)
      tenant_id = spn['tenant_id']
      client_id = spn['client_id']
      secret = spn['secret']
      @token_provider ||= begin
        MsRestAzure::ApplicationTokenProvider.new(tenant_id, client_id, secret, token_audience)
      end
    end

    def vault_request_url(vault, secret_name, version, resource = 'secrets', api_version = '2015-06-01')
      base_url = "https://#{vault}.vault.azure.net/#{resource}/#{secret_name}"
      base_url << "/#{version}" unless version.nil?
      base_url << "?api-version=#{api_version}"
      Chef::Log.debug("Generated vault url: #{base_url}")
      base_url
    end

    def validate_service_principal!(spn)
      spn['tenant_id'] ||= ENV['AZURE_TENANT_ID']
      spn['client_id'] ||= ENV['AZURE_CLIENT_ID']
      spn['secret'] ||= ENV['AZURE_CLIENT_SECRET']
      raise 'Invalid SPN info provided' unless spn['tenant_id'] && spn['client_id'] && spn['secret']
    end
  end
end

Chef::Recipe.include Azure::KeyVault
Chef::Resource.include Azure::KeyVault
