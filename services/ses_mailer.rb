class SESMailer
  # @param [Hash] options Passes along initialization options to
  #   [Aws::SES::Client.new](http://docs.aws.amazon.com/sdkforruby/api/Aws/SES/Client.html#initialize-instance_method).
  def initialize(options = {})
    @client = Aws::SES::Client.new(options)
  end

  # Rails expects this method to exist, and to handle a Mail::Message object
  # correctly. Called during mail delivery.
  def deliver!(message)
    send_opts = {}
    send_opts[:raw_message] = {}
    send_opts[:raw_message][:data] = message.to_s

    if message.respond_to?(:destinations)
      send_opts[:destinations] = message.destinations
    end

    @client.send_raw_email(send_opts)
  end

  # ActionMailer expects this method to be present and to return a hash.
  def settings
    {}
  end
end
