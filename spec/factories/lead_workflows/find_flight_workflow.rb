# frozen_string_literal: true

FactoryBot.define do
  factory :find_flight_workflow, class: 'LeadWorkflows::FindFlightWorkflow' do
    lead_id { 10_100 }
    type { 'LeadWorkflows::FindFlightWorkflow' }
    status { :created }
    resume_at { Time.current }
    context { { 'step' => 0 } }
  end
end
