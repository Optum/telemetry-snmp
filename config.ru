# frozen_string_literal: true

require 'socket'

require 'puma'
require 'rack'
require 'sinatra'
require 'oj'
require 'multi_json'

require 'telemetry/snmp'
require 'telemetry/snmp/api'
Telemetry::Snmp.bootstrap
run Telemetry::Snmp::API
