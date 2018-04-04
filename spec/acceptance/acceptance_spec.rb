# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'advanced_security_policy', unless: UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do
  context 'with default parameters' do
    it 'works idempotently with no errors' do
      pp = <<-ASP
      include advanced_security_policy

      advanced_security_policy { 'Application: Specify the maximum log file size (KB)':
        policy_value => '65000',
      }
      ASP

      # Run it twice and test for idempotency
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes:  true)
    end

    describe command('C:\Windows\System32\LGPO.exe /parse /q /m \'C:\Windows\System32\GroupPolicy\Machine\Registry.pol\'') do
      its(:stdout) { is_expected.to match %r{Software\\Policies\\Microsoft\\Windows\\EventLog\\Application} }
      its(:stdout) { is_expected.to match %r{MaxSize} }
      its(:stdout) { is_expected.to match %r{DWORD:65000} }
    end

    describe file('C:/windows/temp/lgpotemp.txt') do
      its(:content) { is_expected.to match %r{^Software\\Policies\\Microsoft\\Windows\\EventLog\\Application$} }
      its(:content) { is_expected.to match %r{^MaxSize$} }
      its(:content) { is_expected.to match %r{^DWORD:65000$} }
    end
  end
end
