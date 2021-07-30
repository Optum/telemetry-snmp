# frozen_string_literal: true

require_relative 'lib/telemetry/snmp/version'

Gem::Specification.new do |spec|
  spec.name          = 'telemetry-snmp'
  spec.version       = Telemetry::Snmp::VERSION
  spec.authors       = ['Esity']
  spec.email         = ['matt.iverson@optum.com']

  spec.summary       = 'Telemetry snmp gem for collecting snmp data'
  spec.description   = 'A gem that grabs data from SNMP sources and sends it to Telemetry::AMQP'
  spec.homepage      = 'https://github.com/Optum/telemetry-snmp'
  spec.license       = 'Apache-2.0'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.5.0')

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/Optum/telemetry-snmp'
  spec.metadata['bug_tracker_uri'] = 'https://github.com/Optum/telemetry-snmp/issues'
  spec.metadata['changelog_uri'] = 'https://github.com/Optum/telemetry-snmp/blob/main/CHANGELOG.md'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.require_paths = ['lib']

  spec.add_dependency 'concurrent-ruby', '>= 1.1.7'
  spec.add_dependency 'concurrent-ruby-ext', '>= 1.1.7'
  spec.add_dependency 'connection_pool', '>= 2.2.3'
  spec.add_dependency 'faraday'
  spec.add_dependency 'faraday_middleware'
  spec.add_dependency 'faraday-request-timer'
  spec.add_dependency 'multi_json'
  spec.add_dependency 'mysql2'
  spec.add_dependency 'net-http-persistent'
  spec.add_dependency 'net-ldap'
  spec.add_dependency 'netsnmp', '<= 0.4.0'
  spec.add_dependency 'oj', '>= 3.11'
  spec.add_dependency 'puma', '>= 5.1.1'
  spec.add_dependency 'rack', '>= 2.2.3'
  spec.add_dependency 'sequel'
  spec.add_dependency 'sinatra', '>= 2.1.0'
  spec.add_dependency 'sinatra-contrib'

  spec.add_dependency 'telemetry-amqp'
  spec.add_dependency 'telemetry-logger'
  spec.add_dependency 'telemetry-metrics-parser'
end
