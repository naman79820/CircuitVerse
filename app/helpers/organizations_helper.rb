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

  # Returns the FontAwesome class based on the URL domain
  X_HOSTS = %w[twitter.com x.com].freeze

  def x_link?(url)
    host = url_host(url)
    host.present? && X_HOSTS.include?(host)
  end

  def icon_for_url(url)
    host = url_host(url)
    return "fas fa-link" if host.blank?

    case host
    when "github.com" then "fab fa-github"
    when "instagram.com" then "fab fa-instagram"
    when "twitter.com", "x.com" then "custom-icon-x"
    when "linkedin.com" then "fab fa-linkedin"
    when "youtube.com", "youtu.be" then "fab fa-youtube"
    when "discord.com", "discord.gg" then "fab fa-discord"
    when "facebook.com" then "fab fa-facebook"
    when "slack.com" then "fab fa-slack"
    else "fas fa-link"
    end
  end

  def url_host(url)
    uri = URI.parse(url.to_s)
    return nil unless uri.is_a?(URI::HTTP)

    uri.host.to_s.downcase.delete_prefix("www.")
  rescue URI::InvalidURIError
    nil
  end

  # Cleans up the URL for display (removes https:// and trailing slashes)
  def format_url_text(url)
    return "" if url.blank? || !url.match?(%r{\Ahttps?://}i)

    url.sub(%r{^https?://(www\.)?}, "").chomp("/")
  end
end
