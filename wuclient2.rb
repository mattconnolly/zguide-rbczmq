#!/usr/bin/env ruby
require 'rbczmq'
require 'scanf'

context = ZMQ::Context.new
subscriber = context.socket :SUB
# read from proxied socket
subscriber.connect('tcp://localhost:15556')

filter = ARGV[0] || '10001 '
subscriber.subscribe(filter)

zipcode = ''
total_temp = 0
100.times do
  s = subscriber.recv
  puts s
  zipcode, temperature, humidity = s.scanf('%d %d %d')
  total_temp += temperature
end

total_temp /= 100.0
puts "Average temperature for zipcode '#{zipcode}' was #{total_temp}°C"
