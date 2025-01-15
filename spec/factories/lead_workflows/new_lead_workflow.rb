# frozen_string_literal: true

FactoryBot.define do
  factory :new_lead_workflow, class: 'LeadWorkflows::NewLeadWorkflow' do
    lead_id { 10_100 }
    type { 'LeadWorkflows::NewLeadWorkflow' }
    status { :created }
    resume_at { Time.current }
    context { { 'step' => 0 } }
  end
end
