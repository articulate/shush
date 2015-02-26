require 'mail'

class MailNotifier
  class << self
    FROM = "Shush <shush@articulate.com>"

    def notify_read(email, link, is_ttl:)
      message = Mail.new do
        to email
        from FROM
        subject "Shush: Message Read"

        text_part do
          msg = "Your message (#{link}) was read"
          msg += is_ttl ? "." : "and destroyed."

          body msg
        end

        html_part do
          msg = "<h2>Your message (<i>#{link}</i>) was read"
          msg += is_ttl ? "." : " and destroyed."
          msg += "</h2>"

          content_type 'text/html; charset=UTF-8'
          body msg
        end
      end

      message.deliver
    end
  end
end
