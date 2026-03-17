# frozen_string_literal: true

require "rails_helper"

describe OrganizationPolicy do
  subject { described_class.new(user, organization) }

  before do
    @org = FactoryBot.create(:organization)
    @org_admin = FactoryBot.create(:user)
    @org_member = FactoryBot.create(:user)
    FactoryBot.create(:organization_member, organization: @org, user: @org_admin, role: :admin)
    FactoryBot.create(:organization_member, organization: @org, user: @org_member, role: :member)
  end

  context "when the user is an org admin" do
    let(:user) { @org_admin }
    let(:organization) { @org }

    it { is_expected.to permit(:show) }
    it { is_expected.to permit(:update) }
    it { is_expected.to permit(:destroy) }
    it { is_expected.to permit(:admin_access) }
    it { is_expected.to permit(:manage_members) }
  end

  context "when the user is a regular member" do
    let(:user) { @org_member }
    let(:organization) { @org }

    it { is_expected.to permit(:show) }
    it { is_expected.not_to permit(:update) }
    it { is_expected.not_to permit(:destroy) }
    it { is_expected.not_to permit(:admin_access) }
    it { is_expected.not_to permit(:manage_members) }
  end

  context "when the user is not a member" do
    let(:user) { FactoryBot.create(:user) }
    let(:organization) { @org }

    it { is_expected.not_to permit(:show) }
    it { is_expected.not_to permit(:update) }
    it { is_expected.not_to permit(:destroy) }
    it { is_expected.not_to permit(:admin_access) }
  end

  context "when the user is a site admin" do
    let(:user) { FactoryBot.create(:user, admin: true) }
    let(:organization) { @org }

    it { is_expected.to permit(:show) }
    it { is_expected.to permit(:update) }
    it { is_expected.to permit(:destroy) }
    it { is_expected.to permit(:admin_access) }
  end
end
