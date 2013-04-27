#!/usr/bin/env ruby
require 'rbczmq'
require 'scanf'

context = ZMQ::Context.new
subscriber = context.socket :SUB
subscriber.connect('tcp://localhost:5556')

filter = ARGV[0] || '10001 '
subscriber.subscribe(filter)

zipcode = ''
total_temp = 0
100.times do
  s = subscriber.recv
  zipcode, temperature, humidity = s.scanf('%d %d %d')
  total_temp += temperature
end

total_temp /= 100.0
puts "Average temperature for zipcode '#{zipcode}' was #{total_temp}°C"
