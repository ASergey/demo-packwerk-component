# frozen_string_literal: true

FactoryBot.define do
  factory :plans_changed_workflow, class: 'LeadWorkflows::PlansChangedWorkflow' do
    lead_id { 10_100 }
    type { 'LeadWorkflows::PlansChangedWorkflow' }
    status { :created }
    resume_at { Time.current }
  end
end
