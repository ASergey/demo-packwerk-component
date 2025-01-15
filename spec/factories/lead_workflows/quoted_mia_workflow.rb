# frozen_string_literal: true

FactoryBot.define do
  factory :quoted_mia_workflow, class: 'LeadWorkflows::QuotedMIAWorkflow' do
    lead_id { 10_100 }
    type { 'LeadWorkflows::QuotedMIAWorkflow' }
    status { :created }
    resume_at { Time.current }
    context { { 'step' => 0 } }
  end
end
