# frozen_string_literal: true

FactoryBot.define do
  factory :bad_number_workflow, class: 'LeadWorkflows::BadNumberWorkflow' do
    lead_id { 10_100 }
    type { 'LeadWorkflows::BadNumberWorkflow' }
    status { :created }
    resume_at { Time.current }
    context { { 'step' => 0 } }
  end
end
