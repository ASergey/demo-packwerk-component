# frozen_string_literal: true

class CreateLeadWorkflows < ActiveRecord::Migration[6.1]
  def change
    create_table :lead_workflows do |t|
      t.string :type, null: false
      t.integer :lead_id, null: false, index: true
      t.datetime :resume_at, null: false, index: true
      t.jsonb :context
      t.string :error
      t.string :status, null: false, default: 'created'

      t.timestamps
    end

    add_check_constraint :lead_workflows, "status IN ('created', 'in_progress', 'finished')",
      name: 'lead_workflows_status_check'
  end
end
