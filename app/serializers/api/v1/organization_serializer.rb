# frozen_string_literal: true

class Api::V1::OrganizationSerializer
  include FastJsonapi::ObjectSerializer

  attributes :name, :slug, :description, :created_at, :updated_at

  attributes :member_count do |org|
    org.organization_members.size
  end

  attributes :group_count do |org|
    org.groups.size
  end

  has_many :groups
end
