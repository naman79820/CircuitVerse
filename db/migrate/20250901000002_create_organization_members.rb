# frozen_string_literal: true

class CreateOrganizationMembers < ActiveRecord::Migration[8.0]
  def change
    create_table :organization_members do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :role, null: false, default: 3

      t.timestamps
    end

    add_index :organization_members, %i[organization_id user_id], unique: true
  end
end
