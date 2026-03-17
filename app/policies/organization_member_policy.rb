# frozen_string_literal: true

class OrganizationMemberPolicy < ApplicationPolicy
  attr_reader :user, :organization_member

  def initialize(user, organization_member)
    @user = user
    @organization_member = organization_member
  end

  def create?
    org_admin?
  end

  def update?
    org_admin?
  end

  def destroy?
    org_admin? || organization_member.user_id == user.id
  end

  private

    def org_admin?
      user.admin? || organization_member.organization.admin?(user)
    end
end
