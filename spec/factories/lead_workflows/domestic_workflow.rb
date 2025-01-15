# frozen_string_literal: true

FactoryBot.define do
  factory :domestic_workflow, class: 'LeadWorkflows::DomesticWorkflow' do
    lead_id { 10_100 }
    type { 'LeadWorkflows::DomesticWorkflow' }
    status { :created }
    resume_at { Time.current }
  end
end
