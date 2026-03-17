# frozen_string_literal: true

require "rails_helper"

RSpec.describe Organization, type: :model do
  before do
    @primary_mentor = FactoryBot.create(:user)
  end

  describe "associations" do
    it { is_expected.to have_many(:organization_members) }
    it { is_expected.to have_many(:users).through(:organization_members) }
    it { is_expected.to have_many(:groups) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_length_of(:name).is_at_least(2) }
  end

  describe "role checks" do
    before do
      @org = FactoryBot.create(:organization)
      @admin = FactoryBot.create(:user)
      @regular = FactoryBot.create(:user)
      @outsider = FactoryBot.create(:user)
      FactoryBot.create(:organization_member, organization: @org, user: @admin, role: :admin)
      FactoryBot.create(:organization_member, organization: @org, user: @regular, role: :member)
    end

    it "identifies admins" do
      expect(@org.admin?(@admin)).to be true
      expect(@org.admin?(@regular)).to be false
    end

    it "identifies members" do
      expect(@org.member?(@admin)).to be true
      expect(@org.member?(@regular)).to be true
      expect(@org.member?(@outsider)).to be false
    end

    it "returns role for a given user" do
      expect(@org.role_for(@admin)).to eq("admin")
      expect(@org.role_for(@regular)).to eq("member")
      expect(@org.role_for(@outsider)).to be_nil
    end
  end
end
