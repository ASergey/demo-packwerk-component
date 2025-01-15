# frozen_string_literal: true

RSpec.describe LeadWorkflows::DomesticWorkflow do
  it_behaves_like 'a triggerable lead workflow', [LeadWorkflows::DomesticWorkflow::LEAD_LABEL_DOMESTIC]
  it_behaves_like 'a resumable lead workflow', :domestic_workflow,
    [LeadWorkflows::DomesticWorkflow::LEAD_LABEL_DOMESTIC]
end
