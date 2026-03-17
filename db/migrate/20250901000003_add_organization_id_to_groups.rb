# frozen_string_literal: true

class AddOrganizationIdToGroups < ActiveRecord::Migration[8.0]
  def change
    add_reference :groups, :organization, null: true, foreign_key: true
  end
end
