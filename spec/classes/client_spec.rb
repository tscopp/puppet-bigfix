require 'spec_helper'
describe 'bigfix::client', :type => :class do

  package_name = 'BESAgent'
  service_name = 'besclient'

  # Ensure that not providing URL or license file does cause a failure.
  context 'when neither providing URL nor license file' do
    let(:params) {
      {
        :license_file_url => :undef,
        :license_file     => :undef,
      }
    }

    it { is_expected.to compile.and_raise_error(%r{.*}) }

  end
  
  # Ensure that providing both URL and license file does cause a failure.
  context 'when providing both URL and license file' do
    let(:params) {
      {
        :license_file_url => 'http://www.example.org/actionsite.axfr',
        :license_file     => 'undef',
      }
    }

    it { is_expected.to compile.and_raise_error(%r{.*}) }

  end

  context 'when using URL to download actionsite.axfr file' do 
    let(:params) {
      {
        :license_file_url => 'http://www.google.com/actionsite.axfr',
      }
    }
  
    it { is_expected.to compile.with_all_deps }
  
    it do 
      is_expected.to contain_file('/etc/opt/BESClient').with({
        'ensure' => 'directory',
      })

    # TODO:  how to test this?
    #      should contain_file('/etc/opot/BESClient/actionsite.afxm').with({
    #        'ensure' => 'file',
    #      })
  
      should contain_package(package_name).with({
        'ensure' => 'installed',
      })
  
      should contain_service(service_name).with({
        'ensure' => 'running',
      })
    end

  end

end
