# frozen_string_literal: true

class OrganizationDashboardShellComponent < ViewComponent::Base
  TAB_BASE_CLASSES = "org-dash-tab d-inline-flex align-items-center rounded-3 fw-medium text-decoration-none"

  renders_one :tab_content

  def initialize(organization:, active_tab:)
    super()
    @organization = organization
    @active_tab = active_tab
  end

  def tab_class(tab)
    "#{TAB_BASE_CLASSES} #{'is-active' if @active_tab == tab}"
  end

  def show_settings_tab?
    helpers.policy(@organization).admin_access?
  end
end
