require 'ffi-rzmq'
require 'securerandom'

context = ZMQ::Context.new
publisher = context.socket(ZMQ::PUB)
rc = publisher.bind('tcp://*:5556')
fail if rc != 0
rc = publisher.bind('ipc://weather.ipc')
fail if rc != 0

rand = Random.new(Time.now.to_i)
loop do
  zipcode = rand.rand(100000)
  temp = rand.rand(119) - 62 # go metric!
  relhumidity = rand.rand(50) + 10
  update = "%05d %d %d" % [zipcode, temp, relhumidity]
  publisher.send_string(update)
end
