# frozen_string_literal: true

RSpec.shared_examples 'a triggerable lead workflow' do |labels|
  describe '.maybe_trigger' do
    subject(:maybe_trigger) { described_class.maybe_trigger(msg) }

    let(:msg) { Events::Message.new(type: 'Leads::LeadLabelAssigned', data:) }
    let(:data) { attributes_for(:lead_label_assigned_event, lead_id:, label: labels.first) }
    let(:lead_id) { 10_100 }

    before do
      allow(Leads).to receive_messages(find: build(:lead_dto))
      allow(Contacts).to receive_messages(find: build(:contact_dto))
    end

    labels.each do |label|
      context "with #{label} label" do
        let(:data) { attributes_for(:lead_label_assigned_event, lead_id:, label:) }

        it 'creates a new workflow', :freeze_time do
          workflow = maybe_trigger
          expect(workflow).to be_a(described_class)
          expect(workflow.lead_id).to eq(lead_id)
          expect(workflow.context).to include('step' => 0)
          expect(workflow).to be_created
          expect(workflow.resume_at).to eq described_class.first_resume_at
        end
      end
    end

    context 'with any other label' do
      let(:data) { attributes_for(:lead_label_assigned_event, lead_id:, label: 'other') }

      it 'does not trigger workflow' do
        expect { maybe_trigger }.not_to change(described_class, :count)
        expect(maybe_trigger).to be_nil
      end
    end
  end
end
