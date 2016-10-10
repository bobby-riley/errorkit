require 'action_mailer'

module Errorkit
  class ErrorsMailer < ActionMailer::Base
    before_action :append_view_paths

    helper_method :error, :limit

    self.mailer_name = 'errors'

    def error_notification(error_id)
      @error = Error.find(error_id)

      mail(:to => mailer_recipients,
           :from => mailer_sender,
           :subject => mailer_subject) do |format|
        format.html { render "#{mailer_name}/error_notification" }
      end
    end

    protected

    def error
      @error
    end

    def limit(hash)
      hash.each do |k, v|
        if v.is_a?(Hash)
          limit(v)
        else
          hash[k] = v[0..1024] + "..." if v.length > 1024
        end
      end
    end

    def mailer_recipients
      Errorkit.config.mailer_recipients
    end

    def mailer_sender
      Errorkit.config.mailer_sender
    end

    def mailer_subject
      message = error.message
      message = message[0..27] + '...' if message.length > 30

      "[#{error.environment || 'Error'}] #{error.exception}: #{message}"
    end

    def append_view_paths
      append_view_path Pathname.new(File.expand_path('../../../', __FILE__)).join('lib', 'generators', 'errorkit', 'templates', 'app', 'views')
    end
  end
end
