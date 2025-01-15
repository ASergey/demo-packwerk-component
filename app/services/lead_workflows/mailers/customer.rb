# frozen_string_literal: true

module LeadWorkflows
  module Mailers
    class Customer < ::Mailer::Base
      include AfterCommitEverywhere
      include DI[factory: 'services.email_data.customer']

      def call(**)
        email_data = factory.new(**).create
        after_commit { super(email_data) }
      end

      def deliver_without_activity_recording(_)
        # recording activity
      end
    end
  end
end
