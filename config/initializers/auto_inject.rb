# frozen_string_literal: true

module LeadWorkflows
  class DryContainer
    extend Dry::Container::Mixin

    namespace(:services) do
      register(:execute_workflow) { ExecuteWorkflow.new }

      namespace(:email_data) do
        register(:customer) { EmailData::CustomerEmail }
        register(:agent) { EmailData::AgentEmail }
      end

      namespace(:mailers) do
        register(:customer) { Mailers::Customer.new }
        register(:agent) { Mailers::Agent.new }
      end
    end

    namespace :queries do
      register(:ready_to_resume) { ReadyToResumeQuery.new }
    end

    namespace :workers do
      register(:execute_workflow) { ExecuteWorkflowJob }
    end
  end

  DI = Dry::AutoInject(DryContainer)
  DC = ->(key) { DryContainer.resolve(key) }
end
