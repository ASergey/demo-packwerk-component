# frozen_string_literal: true

FactoryBot.define do
  factory :new_quote_workflow, class: 'LeadWorkflows::NewQuoteWorkflow' do
    lead_id { 10_100 }
    type { 'LeadWorkflows::NewQuoteWorkflow' }
    status { :created }
    resume_at { Time.current }
    context { { 'quote_id' => 10_100, 'status' => 'new' } }
  end
end
