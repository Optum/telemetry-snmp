# Telemetry::Snmp

### Telemetry::Snmp Collector Service
This is a servce that runs and collects SNMP metrics at whatever frequency is defined inside the basement. As you need
additional collectors, you can scale this out to give you more parallel workers

You can start this service by running
```ruby
bundle update
bundle exec exe/snmp_collector
```


### Telemetry::Snmp::API
The API allows for you to remotely CRUD devices, oids, users, device credentials, etc  
The Routes are available via a [postman json](https://github.com/Optum/telemetry-snmp/blob/main/telemetry-snmp.json)  

## OID Mappings
The oid_walks table is the most utilized and probably what you are looking for. 
Table Layout
```json
{
  "oid": "the oid you want to grab metrics from(walk)",
  "oid_index": "the oid to use as an index for naming",
  "measurement_name": "what name to name the measurement",
  "active": 1
}
```


## Settings
Telemetry::Snmp::Publisher
```ruby
ENV['telemetry.snmp.amqp.username'] = 'guest'
ENV['telemetry.snmp.amqp.password'] = 'guest'
ENV['telemetry.snmp.amqp.nodes'] = 'localhost'
ENV['telemetry.snmp.amqp.vhost'] = 'telemetry'
ENV['telemetry.snmp.amqp.port'] = '5672'
ENV['telemetry.snmp.amqp.use_ssl'] = 'false'
ENV['telemetry.snmp.amqp.exchange_name'] = 'telemetry.snmp'
```

Telemetry::Snmp::Data
```ruby
ENV['telemetry.snmp.data.adapter'] = 'mysql2'
ENV['telemetry.snmp.data.username'] = 'root'
ENV['telemetry.snmp.data.password'] = ''
ENV['telemetry.snmp.data.database'] = 'telemetry_snmp'
ENV['telemetry.snmp.data.host'] = '127.0.0.1'
ENV['telemetry.snmp.data.port'] = '3306'
ENV['telemetry.snmp.data.max_connections'] = '16'
ENV['telemetry.snmp.data.pool_timeout'] = '2'
ENV['telemetry.snmp.data.preconnect'] = 'concurrently'
```
