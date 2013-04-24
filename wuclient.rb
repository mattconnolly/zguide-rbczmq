#!/usr/bin/env ruby
require 'ffi-rzmq'
require 'scanf'

context = ZMQ::Context.new
subscriber = context.socket(ZMQ::SUB)
rc = subscriber.connect('tcp://localhost:5556')
fail unless rc == 0

filter = ARGV[0] || '10001 '
subscriber.setsockopt(ZMQ::SUBSCRIBE, filter)

zipcode = ''
total_temp = 0
100.times do
  s=''
  rc = subscriber.recv_string(s)
  fail if rc < 0
  zipcode, temperature, humidity = s.scanf('%d %d %d')
  total_temp += temperature
end

total_temp /= 100.0
puts "Average temperature for zipcode '#{zipcode}' was #{total_temp}°C"
