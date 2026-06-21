# frozen_string_literal: true

module OrganizationsHelper
  # Returns the organization logo attachment if present,
  # otherwise falls back to the same default image used for user profiles.
  def organization_logo(attachment)
    if attachment.attached?
      attachment
    else
      image_path("/images/thumb/Default.jpg")
    end
  end
end
