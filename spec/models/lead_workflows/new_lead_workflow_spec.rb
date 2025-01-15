# frozen_string_literal: true

RSpec.describe LeadWorkflows::NewLeadWorkflow do
  it_behaves_like 'a resumable lead workflow', :new_lead_workflow,
    [LeadWorkflows::NewLeadWorkflow::LEAD_LABEL_NONE]

  describe '.maybe_trigger' do
    subject(:maybe_trigger) { described_class.maybe_trigger(msg) }

    let(:label) { 'none' }
    let(:msg) { Events::Message.new(type: 'Leads::LeadCreated', data:) }
    let(:data) { attributes_for(:lead_created_event, lead_id:, label:) }
    let(:lead_id) { 10_100 }

    it 'creates a new workflow', :freeze_time do
      workflow = maybe_trigger
      expect(workflow).to be_a(described_class)
      expect(workflow.lead_id).to eq(lead_id)
      expect(workflow.context).to include('step' => 0)
      expect(workflow).to be_created
      expect(workflow.resume_at).to eq described_class.first_resume_at
    end

    context 'with any other label' do
      let(:label) { 'other' }

      it 'does not trigger workflow' do
        expect { maybe_trigger }.not_to change(described_class, :count)
        expect(maybe_trigger).to be_nil
      end
    end

    context 'with any other event type' do
      let(:msg) { Events::Message.new(type: 'Leads::LeadLabelAssigned', data:) }
      let(:data) { attributes_for(:lead_label_assigned_event, lead_id:, label:) }

      it 'does not trigger workflow' do
        expect { maybe_trigger }.not_to change(described_class, :count)
        expect(maybe_trigger).to be_nil
      end
    end
  end
end
