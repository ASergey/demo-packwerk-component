# frozen_string_literal: true

class AddMostRecentAndReturngingToLeadWorkflowLeads < ActiveRecord::Migration[7.2]
  def change
    change_table :lead_workflow_leads, bulk: true do |t|
      t.column :most_recent, :boolean, null: false, default: false
      t.column :returning, :boolean, null: false, default: false
    end

    add_index :lead_workflow_leads, %i[lead_id contact_id], unique: true, where: 'most_recent IS TRUE'
  end
end
