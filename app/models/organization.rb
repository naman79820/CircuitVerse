# frozen_string_literal: true

class Organization < ApplicationRecord
  extend FriendlyId

  friendly_id :name, use: :slugged

  validates :name, presence: true, length: { minimum: 2 }
  validates :slug, uniqueness: true

  has_many :organization_members, dependent: :destroy
  has_many :users, through: :organization_members
  has_many :groups, dependent: :nullify

  def admin?(user)
    organization_members.exists?(user_id: user.id, role: :admin)
  end

  def group_lead?(user)
    organization_members.exists?(user_id: user.id, role: %i[admin group_lead])
  end

  def instructor?(user)
    organization_members.exists?(user_id: user.id, role: %i[admin group_lead instructor])
  end

  def member?(user)
    organization_members.exists?(user_id: user.id)
  end

  def role_for(user)
    organization_members.find_by(user_id: user.id)&.role
  end

  def oidc_configured?
    oidc_client_id.present? && oidc_issuer.present?
  end
end
