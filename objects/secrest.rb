require 'active_support/core_ext/numeric/time'
require 'action_view'
require 'action_view/helpers'

class Secrest
  include ActionView::Helpers::DateHelper

  DEFAULT_EXPIRE = 1440
  TIMES = {
    "10 minutes" => 10,
    "1 hour"     => 60,
    "1 day"      => 1440,
    "1 week"     => 10080,
  }

  DATA_KEYS = %i[
    message
    is_ttl
    email
    notify
  ]

  attr_accessor :message, :ttl, :email

  def self.from_redis(data, expiry)
    new data[:message],
      ttl: to_minutes(expiry),
      is_ttl: bool(data[:is_ttl]),
      notify: bool(data[:notify]),
      email: data[:email]
  end

  def initialize(message, ttl: TIMES.values.max, is_ttl: false, notify: false, email: nil)
    @message = message

    @is_ttl = is_ttl
    @ttl = (auto_expire? ? ttl.to_i : TIMES.values.max)  # force an auto expire of max time

    @notify = notify
    @email = email
  end

  def expire_in_words
    if auto_expire?
      "in #{time_ago_in_words(ttl.minutes.from_now)}"
    else
      "when read"
    end
  end

  def expire_in_seconds
    to_seconds @ttl
  end

  def auto_expire?
    !!@is_ttl
  end

  def notify?
    !!@notify
  end

  def to_h
    {
      message: message,
      is_ttl: auto_expire?,
      email: email,
      notify: notify?
    }
  end

  private

  def to_seconds(time)
    time * 60
  end

  # Redis conversion methods
  def self.bool(val)
    val == "true"
  end

  def self.to_minutes(time)
    (time.to_f / 60).round(2)
  end
end
