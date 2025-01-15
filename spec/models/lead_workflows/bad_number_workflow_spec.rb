# frozen_string_literal: true

RSpec.describe LeadWorkflows::BadNumberWorkflow do
  it_behaves_like 'a triggerable lead workflow', [LeadWorkflows::BadNumberWorkflow::LEAD_LABEL_BAD_NUMBER]
  it_behaves_like 'a resumable lead workflow', :bad_number_workflow,
    [LeadWorkflows::BadNumberWorkflow::LEAD_LABEL_BAD_NUMBER]
end
