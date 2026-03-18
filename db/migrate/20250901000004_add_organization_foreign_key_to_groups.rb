# frozen_string_literal: true

class AddOrganizationForeignKeyToGroups < ActiveRecord::Migration[8.0]
  def change
    add_foreign_key :groups, :organizations, validate: false
  end
end
