# frozen_string_literal: true

class OrganizationMember < ApplicationRecord
  belongs_to :organization
  belongs_to :user

  enum :role, { admin: 0, group_lead: 1, instructor: 2, member: 3 }

  validates :user_id, uniqueness: { scope: :organization_id }
  validates :role, presence: true

  after_commit :notify_member, on: :create

  private

    def notify_member
      OrganizationMailer.member_added_email(user, organization).deliver_later
    end
end
