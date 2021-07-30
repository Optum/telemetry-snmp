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
    ENV['telemetry.snmp.amqp.username'] = 'foobar'
    expect(described_class.username).to eq 'foobar'
    ENV['telemetry.snmp.amqp.username'] = nil
  end

  it 'should have a password' do
    expect(described_class.password).to eq 'guest'
    ENV['telemetry.snmp.amqp.password'] = 'foobar'
    expect(described_class.password).to eq 'foobar'
    ENV['telemetry.snmp.amqp.password'] = nil
    expect(described_class.password).to eq 'guest'
  end

  it 'should have a vhost' do
    expect(described_class.vhost).to eq 'telemetry'
    ENV['telemetry.snmp.amqp.vhost'] = 'foobar'
    expect(described_class.vhost).to eq 'foobar'
    ENV['telemetry.snmp.amqp.vhost'] = nil
    expect(described_class.vhost).to eq 'telemetry'
  end

  it 'should have a port' do
    expect(described_class.port).to eq 5672
    ENV['telemetry.snmp.amqp.port'] = '8811'
    expect(described_class.port).to eq 8811
    ENV['telemetry.snmp.amqp.port'] = nil
    expect(described_class.port).to eq 5672
  end

  it 'should have nodes' do
    expect(described_class.nodes).to be_a Array
    expect(described_class.nodes).to eq ['localhost']
    ENV['telemetry.snmp.amqp.nodes'] = 'foo,bar'
    expect(described_class.nodes).to eq %w[foo bar]
    ENV['telemetry.snmp.amqp.nodes'] = nil
  end

  it 'should have an exchange name' do
    expect(described_class.exchange_name).to eq 'telemetry.snmp'
    ENV['telemetry.snmp.amqp.exchange_name'] = 'test_exchange'
    expect(described_class.exchange_name).to eq 'test_exchange'
    ENV['telemetry.snmp.amqp.exchange_name'] = nil
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
    ENV['telemetry.snmp.amqp.use_ssl'] = 'true'
    expect(described_class.use_ssl?).to eq true
    ENV['telemetry.snmp.amqp.use_ssl'] = 'foobar'
    expect(described_class.use_ssl?).to eq false
    ENV['telemetry.snmp.amqp.use_ssl'] = '1'
    expect(described_class.use_ssl?).to eq true
    ENV['telemetry.snmp.amqp.use_ssl'] = '0'
    expect(described_class.use_ssl?).to eq false
    ENV['telemetry.snmp.amqp.use_ssl'] = nil
    expect(described_class.use_ssl?).to eq false
  end

  it 'should be able to start!' do
    expect { described_class.start! }.not_to raise_exception
  end

  it 'should be able to start! with options' do
    opts = {
      amqp: {
        vhost: 'telegraf',
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
