#
# Cookbook Name:: azure-cookbook
# Spec:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

require 'spec_helper'

describe 'microsoft_azure::default' do
  context 'When all attributes are default, on an unspecified platform' do
    let(:chef_run) do
      ChefSpec::ServerRunner.new.converge(described_recipe)
    end

    it 'installs the azure gem' do
      expect(chef_run).to install_chef_gem('azure')
    end
  end
end
