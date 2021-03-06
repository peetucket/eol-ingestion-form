#---
# Excerpted from "Agile Web Development with Rails"
# We make no guarantees that this code is fit for any purpose. 
# Visit http://www.pragmaticprogrammer.com for more book information.
#---
require 'pathname'

class SystemNotifier < ActionMailer::Base

  SYSTEM_EMAIL_ADDRESS = $APP_NAME + " <" + $ADMIN_EMAIL + ">"
  EXCEPTION_RECIPIENTS = $ADMIN_EMAIL

  def exception_notification(controller, request, 
                             exception, sent_on=Time.now)

    @subject    = "ERROR: " + $APP_NAME

    @body       = { "controller" => controller, "request" => request,
                    "exception"  => exception,
                    "backtrace"  => sanitize_backtrace(exception.backtrace),
                    "host" => request.env["HTTP_HOST"],
                    "rails_root" => rails_root }
    @sent_on    = sent_on
    @from       = SYSTEM_EMAIL_ADDRESS
    @recipients = EXCEPTION_RECIPIENTS
    @headers    = {}
  end

  private

  def sanitize_backtrace(trace)
    re = Regexp.new(/^#{Regexp.escape(rails_root)}/)
    trace.map do |line| 
      Pathname.new(line.gsub(re, "[RAILS_ROOT]")).cleanpath.to_s 
    end
  end

  def rails_root
    @rails_root ||= Pathname.new(RAILS_ROOT).cleanpath.to_s
  end
end
