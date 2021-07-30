require 'spec_helper'

RSpec.describe Telemetry::Snmp do
  it 'has a version number' do
    expect(Telemetry::Snmp::VERSION).not_to be nil
  end

  it { should be_a Module }
  it { should respond_to :bootstrap }
end
