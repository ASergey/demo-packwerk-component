# frozen_string_literal: true

class AddLeadWorkflowLeads < ActiveRecord::Migration[7.2]
  def change
    create_table :lead_workflow_leads, id: false do |t|
      t.bigint :lead_id, null: false, index: { unique: true }
      t.bigint :contact_id, null: false, index: true
      t.string :phone, index: true
      t.string :email, index: true
      t.jsonb :context, default: '{}', null: false

      t.timestamps
    end
  end
end
