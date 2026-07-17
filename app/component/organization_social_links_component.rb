# frozen_string_literal: true

class OrganizationSocialLinksComponent < ViewComponent::Base
  def initialize(links:)
    super()
    @links = links
  end

  def social_links
    @links.compact_blank.map do |link|
      host = url_host(link)
      {   name: name_for(host),
          url: link,
          logo: logo_for(host) }
    end
  end

  private

    def url_host(url)
      uri = URI.parse(url.to_s)
      return nil unless uri.is_a?(URI::HTTP)

      uri.host.to_s.downcase.delete_prefix("www.")
    rescue URI::InvalidURIError
      nil
    end

    def logo_for(host)
      case host
      when "github.com" then "logos/github-logo-circle.png"
      when "facebook.com" then "logos/facebook-logo.png"
      when "twitter.com", "x.com" then "logos/twitter-x.png"
      when "linkedin.com" then "logos/linkedin-logo.png"
      when "youtube.com"  then "logos/youtube-logo.png"
      else "logos/link-logo.png"
      end
    end

    def name_for(host)
      case host
      when "github.com" then "GitHub"
      when "facebook.com" then "Facebook"
      when "twitter.com", "x.com" then "X"
      when "linkedin.com" then "LinkedIn"
      when "youtube.com"  then "YouTube"
      else "Website"
      end
    end
end
