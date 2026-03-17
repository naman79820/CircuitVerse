# frozen_string_literal: true

class GroupPolicy < ApplicationPolicy
  attr_reader :user, :group

  def initialize(user, group)
    @user = user
    @group = group
    @admin_access = (group.primary_mentor_id == user.id) || user.admin? || org_admin?
  end

  def show_access?
    @admin_access || group.group_members.exists?(user_id: user.id) || org_member?
  end

  def admin_access?
    @admin_access
  end

  def mentor_access?
    @admin_access || @group.group_members.exists?(user_id: user.id, mentor: true) || org_instructor?
  end

  private

    def org_admin?
      group.organization&.admin?(user) || false
    end

    def org_instructor?
      group.organization&.instructor?(user) || false
    end

    def org_member?
      group.organization&.member?(user) || false
    end
end
