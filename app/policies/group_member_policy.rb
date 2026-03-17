# frozen_string_literal: true

class GroupMemberPolicy < ApplicationPolicy
  attr_reader :user, :group_member

  def initialize(user, group_member)
    @user = user
    @group_member = group_member
  end

  def primary_mentor?
    group_member.group.primary_mentor_id == user.id || user.admin? || org_admin?
  end

  def mentor?
    group_member.group.group_members.exists?(user_id: user.id, mentor: true) || primary_mentor?
  end

  private

    def org_admin?
      group_member.group.organization&.admin?(user) || false
    end
end
