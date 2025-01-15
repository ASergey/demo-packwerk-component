# frozen_string_literal: true

FactoryBot.define do
  factory :competitor_workflow, class: 'LeadWorkflows::CompetitorWorkflow' do
    lead_id { 10_100 }
    type { 'LeadWorkflows::CompetitorWorkflow' }
    status { :created }
    resume_at { Time.current }
  end
end
