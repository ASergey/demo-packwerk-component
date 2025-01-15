# frozen_string_literal: true

RSpec.describe LeadWorkflows::NotReadyWorkflow do
  before do
    allow(Leads).to receive_messages(find: build(:lead_dto))
    allow(Contacts).to receive_messages(find: build(:contact_dto))
  end

  it_behaves_like 'a resumable lead workflow', :not_ready_workflow,
    [LeadWorkflows::NotReadyWorkflow::LEAD_LABEL_NOT_READY]

  describe '.maybe_trigger' do
    subject(:maybe_trigger) { described_class.maybe_trigger(msg) }

    let(:msg) { Events::Message.new(type: 'Leads::LeadLabelAssigned', data:) }
    let(:data) do
      attributes_for(
        :lead_label_assigned_event,
        lead_id: lead.id,
        label: LeadWorkflows::NotReadyWorkflow::LEAD_LABEL_NOT_READY
      )
    end
    let(:lead) { create(:workflow_lead, context: { departure_date: }) }
    let(:departure_date) { 300.days.from_now }

    it 'creates a new workflow', :freeze_time do
      workflow = maybe_trigger
      expect(workflow).to be_a(described_class)
      expect(workflow.lead_id).to eq(lead.id)
      expect(workflow.context).to include('step' => 0)
      expect(workflow).to be_created
      expect(workflow.resume_at).to eq described_class.first_resume_at
    end

    context 'with any other label' do
      let(:data) { attributes_for(:lead_label_assigned_event, lead_id: lead.id, label: 'other') }

      it 'does not trigger workflow' do
        expect { maybe_trigger }.not_to change(described_class, :count)
        expect(maybe_trigger).to be_nil
      end
    end

    context 'with lead without departure date' do
      let(:departure_date) { nil }

      it 'does not trigger workflow' do
        expect { maybe_trigger }.not_to change(described_class, :count)
        expect(maybe_trigger).to be_nil
      end
    end
  end

  describe '#complete_step!', :freeze_time do
    subject(:complete_step) { workflow.complete_step! }

    let(:workflow) { create(:not_ready_workflow, lead_id: lead.id, context: { 'step' => 0 }) }
    let(:lead) { create(:workflow_lead, returning:, context: { departure_date: }) }
    let(:departure_date) { 300.days.from_now }
    let(:returning) { false }

    it 'plans to resume workflow in 300 days before departure date' do
      complete_step
      expect(workflow.context).to include('step' => 1)
      expect(workflow).to be_in_progress
      expect(workflow.resume_at).to eq Time.zone.today.beginning_of_day
    end

    context "when lead's departure date is in 59 days" do
      let(:departure_date) { 59.days.from_now }

      it 'plans to resume workflow in 30 days before departure date' do
        complete_step
        expect(workflow.context).to include('step' => 5)
        expect(workflow).to be_in_progress
        expect(workflow.resume_at).to eq 29.days.from_now.beginning_of_day
      end
    end

    context "when lead's departure date is in 2 days" do
      let(:departure_date) { 2.days.from_now }

      it 'plans to resume workflow now' do
        complete_step
        expect(workflow.context).to include('step' => 7)
        expect(workflow).to be_in_progress
        expect(workflow.resume_at).to eq 2.days.from_now
      end
    end

    context "when lead's departure date is 2 days ago" do
      let(:departure_date) { 2.days.ago }

      it 'plans to resume workflow now' do
        complete_step
        expect(workflow.context).to include('step' => 7)
        expect(workflow).to be_in_progress
        expect(workflow.resume_at).to eq 2.days.from_now
      end
    end

    context 'with returning lead when departure date is in 2 days' do
      let(:departure_date) { 2.days.from_now }
      let(:returning) { true }

      it 'sets another next step params' do
        complete_step
        expect(workflow).to be_finished
        expect(workflow.context).to eq({ 'step' => 0 })
      end
    end
  end
end
