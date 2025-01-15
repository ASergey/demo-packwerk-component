# frozen_string_literal: true

module LeadWorkflows
  class Mailer < ApplicationMailer
    def mail_message(**options)
      options.delete(:template_vars).each do |key, value|
        instance_variable_set(:"@#{key}", value)
      end

      mail(options)
    end
  end
end
