# frozen_string_literal: true

class OrganizationPolicy < ApplicationPolicy
  attr_reader :user, :organization

  def initialize(user, organization)
    @user = user
    @organization = organization
  end

  def index?
    user.present?
  end

  def show?
    user.admin? || organization.member?(user)
  end

  def create?
    user.present?
  end

  def update?
    admin_access?
  end

  def destroy?
    admin_access?
  end

  def manage_members?
    admin_access?
  end

  def admin_access?
    user.admin? || organization.admin?(user)
  end
end
