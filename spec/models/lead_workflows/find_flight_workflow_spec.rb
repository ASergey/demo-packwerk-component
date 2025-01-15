# frozen_string_literal: true

RSpec.describe LeadWorkflows::FindFlightWorkflow do
  it_behaves_like 'a triggerable lead workflow', [LeadWorkflows::FindFlightWorkflow::LEAD_LABEL_FIND_FLIGHT]
  it_behaves_like 'a resumable lead workflow', :find_flight_workflow,
    [LeadWorkflows::FindFlightWorkflow::LEAD_LABEL_FIND_FLIGHT]
end
