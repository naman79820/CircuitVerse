# frozen_string_literal: true

class OrganizationMailer < ApplicationMailer
  def member_added_email(user, organization)
    @user = user
    @organization = organization
    mail(to: @user.email, subject: "You've been added to #{@organization.name}")
  end

  def org_created_email(user, organization)
    @user = user
    @organization = organization
    mail(to: @user.email, subject: "#{@organization.name} has been created")
  end
end
