# frozen_string_literal: true

FactoryBot.define do
  factory :slow_play_workflow, class: 'LeadWorkflows::SlowPlayWorkflow' do
    lead_id { 10_100 }
    type { 'LeadWorkflows::SlowPlayWorkflow' }
    status { :created }
    resume_at { Time.current }
    context { { 'step' => 0 } }
  end
end
