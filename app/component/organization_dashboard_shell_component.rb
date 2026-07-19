# frozen_string_literal: true

class OrganizationDashboardShellComponent < ViewComponent::Base
  renders_one :tab_content

  def initialize(organization:, active_tab:, user_organizations:)
    super()
    @organization = organization
    @active_tab = active_tab
    @user_organizations = user_organizations
  end

  def tab_class(tab)
    "org-dash-tab #{'is-active' if @active_tab == tab}"
  end

  def show_settings_tab?
    helpers.policy(@organization).admin_access?
  end

  def initials(organization)
    organization.name.split.pluck(0).first(2).join.upcase
  end

  def current_org?(organization)
    organization.id == @organization.id
  end
end
