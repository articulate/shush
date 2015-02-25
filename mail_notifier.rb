require 'mail'

class MailNotifier
  class << self
    FROM = "Shush <shush@articulate.com>"

    def notify_read(email, link)
      message = Mail.new do
        to email
        from FROM
        subject "Shush: Message Read"

        text_part do
          body "Your message (#{link}) was read and likely destroyed."
        end

        html_part do
          content_type 'text/html; charset=UTF-8'
          body "<h2>Your message (<i>#{link}</i>) was read and likely destroyed.</h2>"
        end
      end

      message.deliver
    end
  end
end
