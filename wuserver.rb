#!/usr/bin/env ruby
require 'rbczmq'
require 'securerandom'

context = ZMQ::Context.new
publisher = context.socket(:PUB)
publisher.bind('tcp://*:5556')

rand = Random.new(Time.now.to_i)
loop do
  zipcode = rand.rand(100000)
  temp = rand.rand(119) - 62 # go metric!
  relhumidity = rand.rand(50) + 10
  update = "%05d %d %d" % [zipcode, temp, relhumidity]
  publisher.send(update)
end
