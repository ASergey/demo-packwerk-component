# frozen_string_literal: true

FactoryBot.define do
  factory :not_ready_workflow, class: 'LeadWorkflows::NotReadyWorkflow' do
    lead_id { 10_100 }
    type { 'LeadWorkflows::NotReadyWorkflow' }
    status { :created }
    resume_at { Time.current }
    context { { 'step' => 0 } }
  end
end
