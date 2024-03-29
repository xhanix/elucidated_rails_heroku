# blog/app/services/publisher.rb
class Publisher
  # In order to publish message we need a exchange name.
  # Note that RabbitMQ does not care about the payload -
  # we will be using JSON-encoded strings
  def self.publish(message = {})
    # grab the fanout exchange
    x = channel.queue("railsEvent",:durable => true, :auto_delete => false)
    # and simply publish message
    x.publish(message.to_json)
  end

  def self.channel
    @channel ||= connection.create_channel.tap do |ch|
      ch.confirm_select
    end
  end

  # We are using default settings here
  # The `Bunny.new(...)` is a place to
  # put any specific RabbitMQ settings
  # like host or port
  def self.connection
    if Rails.env.test?
      BunnyMock.new.start
    else
      @connection ||= Bunny.new(ENV["RABBITMQ_BIGWIG_TX_URL"]).tap do |c|
        c.start
      end
    end
  end
end