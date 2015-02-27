require 'mail'

class MailNotifier
  class << self
    DEFAULT_FROM = "Shush <plukevdh+shush@articulate.com>"

    def notify_read(email, link, is_ttl:)
      begin
        message = Mail.new do
          to email
          from DEFAULT_FROM
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
      rescue => e
        puts "Could not send notification: #{e.message}"
      end
    end
  end
end
