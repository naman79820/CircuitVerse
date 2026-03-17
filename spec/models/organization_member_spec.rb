# frozen_string_literal: true

require "rails_helper"

RSpec.describe OrganizationMember, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:organization) }
    it { is_expected.to belong_to(:user) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:role) }
  end

  describe "roles" do
    it "has the expected role values" do
      expect(described_class.roles).to eq(
        "admin" => 0, "group_lead" => 1, "instructor" => 2, "member" => 3
      )
    end
  end

  describe "uniqueness" do
    it "does not allow duplicate memberships" do
      user = FactoryBot.create(:user)
      org = FactoryBot.create(:organization)
      FactoryBot.create(:organization_member, user: user, organization: org)
      dup = FactoryBot.build(:organization_member, user: user, organization: org)
      expect(dup).not_to be_valid
    end
  end
end
