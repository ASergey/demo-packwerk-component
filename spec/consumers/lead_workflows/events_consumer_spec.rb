# frozen_string_literal: true

RSpec.describe LeadWorkflows::EventsConsumer do
  subject(:consumer) { described_class.new(js, processors: [first_proc, second_proc]) }

  let(:js) { instance_double(NATS::JetStream, pull_subscribe: nil) }
  let(:proc_cls) do
    Struct.new(:filter_subjects) do
      def process_message(_); end
    end
  end

  let(:first_proc) { proc_cls.new(%w[foo bar]) }
  let(:second_proc) { proc_cls.new(%w[bar baz]) }

  before do
    allow(Events::EnsureConsumer).to receive_messages(
      new: instance_double(Events::EnsureConsumer, call: nil)
    )
  end

  it 'delegates message processing' do
    allow(first_proc).to receive(:process_message)
    allow(second_proc).to receive(:process_message)

    consumer.process_message(:msg)

    expect(first_proc).to have_received(:process_message).with(:msg)
    expect(second_proc).to have_received(:process_message).with(:msg)
  end

  it 'combines filter subjects of processors in config' do
    expect(consumer.config).to eq(
      {
        stream_name: 'lead_workflows',
        durable_name: 'lead_workflows',
        deliver_policy: 'new',
        filter_subjects: %w[foo bar baz]
      }
    )
  end

  it 'handles the init arguments correctly' do
    expect(consumer.logger).to be_a Events::Logger
  end
end
