# frozen_string_literal: true

module LeadWorkflows
  module Mailers
    class Agent < ::Mailer::Base
      include AfterCommitEverywhere
      include DI[factory: 'services.email_data.agent']

      def call(**)
        email_data = factory.new(**).create
        after_commit { super(email_data) }
      end

      def record_activity(_)
        # deliver without activity recording
      end
    end
  end
end
