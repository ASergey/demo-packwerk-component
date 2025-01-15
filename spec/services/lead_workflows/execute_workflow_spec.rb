# frozen_string_literal: true

RSpec.describe LeadWorkflows::ExecuteWorkflow do
  subject(:execute_workflow) do
    described_class.new.(workflow)
  end

  let(:lead) { create(:workflow_lead) }
  let(:workflow) { create(:quoted_mia_workflow, lead_id: lead.id) }
  let(:workflow_config) { [{ 'no_action_matches' => nil }] }

  let(:email_to_customer) { instance_double(LeadWorkflows::WorkflowActions::EmailToCustomer, call: true) }
  let(:email_to_agent) { instance_double(LeadWorkflows::WorkflowActions::EmailToAgent, call: true) }
  let(:assign_label_to_lead) { instance_double(LeadWorkflows::WorkflowActions::AssignLabelToLead, call: true) }
  let(:stop_sequences_enrolled) { instance_double(LeadWorkflows::WorkflowActions::StopSequencesEnrolled, call: true) }
  let(:unassign_contact_owner) { instance_double(LeadWorkflows::WorkflowActions::UnassignContactOwner, call: true) }
  let(:mark_recycled) { instance_double(LeadWorkflows::WorkflowActions::MarkAsRecycled, call: true) }

  before do
    allow(workflow).to receive_messages(workflow_config:, resumable?: true, lead:)

    allow(LeadWorkflows::WorkflowActions::EmailToCustomer).to receive(:new).and_return(email_to_customer)
    allow(LeadWorkflows::WorkflowActions::EmailToAgent).to receive(:new).and_return(email_to_agent)
    allow(LeadWorkflows::WorkflowActions::AssignLabelToLead).to receive(:new).and_return(assign_label_to_lead)
    allow(LeadWorkflows::WorkflowActions::StopSequencesEnrolled).to receive(:new).and_return(stop_sequences_enrolled)
    allow(LeadWorkflows::WorkflowActions::UnassignContactOwner).to receive(:new).and_return(unassign_contact_owner)
    allow(LeadWorkflows::WorkflowActions::MarkAsRecycled).to receive(:new).and_return(mark_recycled)
    allow(EventLogger).to receive(:info)
  end

  it 'does not process any workflow action and finishes the workflow' do
    expect { execute_workflow }.to change(workflow, :status).from('created').to('finished')
    LeadWorkflows::ExecuteWorkflow::WORKFLOW_ACTIONS.each_value do |action|
      expect(action.constantize).not_to have_received(:new)
    end
    expect(EventLogger).to have_received(:info).with(
      event: 'lead_workflows.execute_workflow',
      type: workflow.type,
      workflow_id: workflow.id
    )
  end

  context 'when workflow is not resumable' do
    before do
      allow(workflow).to receive(:resumable?).and_return(false)
    end

    it 'finishes the workflow with error' do
      expect { execute_workflow }.to change(workflow, :status).from('created').to('finished')
      expect(workflow.error).to eq('The workflow does not meet conditions to be resumed')
      LeadWorkflows::ExecuteWorkflow::WORKFLOW_ACTIONS.each_value do |action|
        expect(action.constantize).not_to have_received(:new)
      end
    end
  end

  context 'with the next step available' do
    let(:workflow_config) { [{ 'delay' => 'PT0H' }, { 'delay' => 'P1D' }] }

    it 'prepares the next step' do
      expect { execute_workflow }.to change(workflow, :status).from('created').to('in_progress')
      expect(workflow.context).to include('step' => 1)
    end
  end

  context 'with customer email action parameters' do
    let(:workflow_config) do
      [
        {
          email_to_customer: {
            subject: 'subject',
            template_path: 'template_path',
            template_name: 'email_1'
          }
        }
      ]
    end

    it 'calls the customer email action' do
      execute_workflow
      expect(LeadWorkflows::WorkflowActions::EmailToCustomer).to have_received(:new).with(
        lead,
        subject: 'subject',
        template_path: 'template_path',
        template_name: 'email_1',
        step: 0
      )
      expect(email_to_customer).to have_received(:call)
      expect(EventLogger).to have_received(:info).with(
        event: 'lead_workflows.execute_action',
        action: :email_to_customer,
        params: workflow_config.first,
        context: workflow.context.deep_symbolize_keys
      ).with(
        event: 'lead_workflows.execute_workflow',
        type: workflow.type,
        workflow_id: workflow.id
      )
    end
  end

  context 'with agent email action parameters' do
    let(:workflow_config) do
      [
        {
          email_to_agent: {
            subject: 'subject',
            template_path: 'template_path',
            template_name: 'email_1'
          }
        }
      ]
    end

    it 'calls the agent email action' do
      execute_workflow
      expect(LeadWorkflows::WorkflowActions::EmailToAgent).to have_received(:new).with(
        lead,
        subject: 'subject',
        template_path: 'template_path',
        template_name: 'email_1',
        step: 0
      )
      expect(email_to_agent).to have_received(:call)
    end
  end

  context 'with label assignment parameters' do
    let(:workflow_config) do
      [{ assign_label_to_lead: { label: 'label' } }]
    end

    it 'calls the label assignment action' do
      execute_workflow
      expect(LeadWorkflows::WorkflowActions::AssignLabelToLead).to have_received(:new).with(
        lead, label: 'label', step: 0
      )
      expect(assign_label_to_lead).to have_received(:call)
    end
  end

  context 'with stop sequences enrolled parameters' do
    let(:workflow) { build(:bad_number_workflow) }
    let(:workflow_config) do
      [{ stop_sequences_enrolled: nil }]
    end

    it 'calls the stop sequences enrolled action' do
      execute_workflow
      expect(LeadWorkflows::WorkflowActions::StopSequencesEnrolled).to have_received(:new).with(lead, step: 0)
      expect(stop_sequences_enrolled).to have_received(:call)
    end
  end

  context 'with contact owner unassignment parameters' do
    let(:workflow) { build(:quoted_mia_workflow, context: { step: 0 }) }
    let(:workflow_config) do
      [{ unassign_contact_owner: nil }]
    end

    it 'calls the contact owner unassignment action' do
      execute_workflow
      expect(LeadWorkflows::WorkflowActions::UnassignContactOwner).to have_received(:new).with(lead, step: 0)
      expect(unassign_contact_owner).to have_received(:call)
    end
  end

  context 'with contact mark recycled parameters' do
    let(:workflow) { create(:recycle_workflow, context: { step: 0 }) }
    let(:workflow_config) do
      [{ mark_recycled: nil }]
    end

    it 'calls the mark as recycled action' do
      execute_workflow
      expect(LeadWorkflows::WorkflowActions::MarkAsRecycled).to have_received(:new).with(
        lead, step: 0
      )
      expect(mark_recycled).to have_received(:call)
    end

    context 'with error' do
      before do
        allow(LeadWorkflows::WorkflowActions::MarkAsRecycled).to receive(:new).and_raise(LeadWorkflows::WorkflowStale)
      end

      it 'finishes the workflow with error' do
        expect { execute_workflow }.to change(workflow, :status).from('created').to('finished')
        expect(workflow.error).to be_present
      end
    end
  end
end
