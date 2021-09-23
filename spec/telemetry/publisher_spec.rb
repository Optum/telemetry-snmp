require 'spec_helper'
require 'telemetry/snmp/publisher'

RSpec.describe Telemetry::Snmp::Publisher do
  it { should be_a Module }
  it 'should have defaults opts' do
    expect(described_class.opts).to be_a Hash
  end

  it { should respond_to :start! }
  it { should respond_to :push_lines }

  it 'should have a username' do
    expect(described_class.username).to eq 'guest'
    ENV['telemetry_snmp_amqp_username'] = 'foobar'
    expect(described_class.username).to eq 'foobar'
    ENV['telemetry_snmp_amqp_username'] = nil
  end

  it 'should have a password' do
    expect(described_class.password).to eq 'guest'
    ENV['telemetry_snmp_amqp_password'] = 'foobar'
    expect(described_class.password).to eq 'foobar'
    ENV['telemetry_snmp_amqp_password'] = nil
    expect(described_class.password).to eq 'guest'
  end

  it 'should have a vhost' do
    expect(described_class.vhost).to eq 'telemetry'
    ENV['telemetry_snmp_amqp_vhost'] = 'foobar'
    expect(described_class.vhost).to eq 'foobar'
    ENV['telemetry_snmp_amqp_vhost'] = nil
    expect(described_class.vhost).to eq 'telemetry'
  end

  it 'should have a port' do
    expect(described_class.port).to eq 5672
    ENV['telemetry_snmp_amqp_port'] = '8811'
    expect(described_class.port).to eq 8811
    ENV['telemetry_snmp_amqp_port'] = nil
    expect(described_class.port).to eq 5672
  end

  it 'should have nodes' do
    expect(described_class.nodes).to be_a Array
    expect(described_class.nodes).to eq ['localhost']
    ENV['telemetry_snmp_amqp_nodes'] = 'foo,bar'
    expect(described_class.nodes).to eq %w[foo bar]
    ENV['telemetry_snmp_amqp_nodes'] = nil
  end

  it 'should have an exchange name' do
    expect(described_class.exchange_name).to eq 'telemetry.snmp'
    ENV['telemetry_snmp_amqp_exchange_name'] = 'test.exchange'
    expect(described_class.exchange_name).to eq 'test.exchange'
    ENV['telemetry_snmp_amqp_exchange_name'] = nil
  end

  it 'should have publlish_opts' do
    expect(described_class.publish_opts).to be_a Hash
  end

  it 'channel should be a Bunny::Channel' do
    expect(described_class.channel).to be_a Bunny::Channel
  end

  it 'exchange should be_a Bunny::Exchange' do
    expect(described_class.line_exchange).to be_a Bunny::Exchange
  end

  it 'session should be a Bunny::Session' do
    expect(described_class.session).to be_a Telemetry::AMQP::Base
  end

  it 'should support use_ssl' do
    expect(described_class.use_ssl?).to eq false
    ENV['telemetry_snmp_amqp_use_ssl'] = 'true'
    expect(described_class.use_ssl?).to eq true
    ENV['telemetry_snmp_amqp_use_ssl'] = 'foobar'
    expect(described_class.use_ssl?).to eq false
    ENV['telemetry_snmp_amqp_use_ssl'] = '1'
    expect(described_class.use_ssl?).to eq true
    ENV['telemetry_snmp_amqp_use_ssl'] = '0'
    expect(described_class.use_ssl?).to eq false
    ENV['telemetry_snmp_amqp_use_ssl'] = nil
    expect(described_class.use_ssl?).to eq false
  end

  it 'should be able to start!' do
    expect { described_class.start! }.not_to raise_exception
  end

  it 'should be able to start! with options' do
    opts = {
      amqp: {
        vhost: '/',
        nodes: ['localhost', '127.0.0.1'],
        exchange_name: 'telemetry.snmp',
        port: 5672,
        username: 'guest',
        password: 'guest',
        use_ssl: false
      }
    }
    expect(described_class.start!(**opts)).to eq true

    expect(described_class.port).to eq 5672
    expect(described_class.exchange_name).to eq 'telemetry.snmp'
    expect(described_class.nodes.count).to be > 1
  end
end
