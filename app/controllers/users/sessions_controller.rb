# frozen_string_literal: true
class Users::SessionsController < Devise::SessionsController
  prepend_before_action :check_captcha, only: [:create]
  before_action :handle_already_authenticated, only: [:new]

  def create
    super do |user|
      remember_me = params.dig(:user, :remember_me) == "1"

      token = JsonWebToken.encode(
        user_id: user.id, username: user.name, email: user.email, remember_me: remember_me
      )

      cookie_options = {
        value: token,
        secure: Rails.env.production?,
        same_site: :strict
      }
      cookie_options[:expires] = 2.weeks.from_now if remember_me
      cookies[:cvt] = cookie_options

      # ── Tauri Desktop Auth ──────────────────────────────────────────
      if session.delete(:tauri_login)
        @tauri_token = token
        render "users/sessions/tauri_callback", layout: false
        return
      end
      # ───────────────────────────────────────────────────────────────
    end
  end

  def destroy
    super do
      cookies.delete(:cvt)
    end
  end

  def new
    session[:tauri_login] = true if params[:tauri] == "1"
    super
  end

  private

    def handle_already_authenticated
      return unless params[:tauri] == "1"
      return unless current_user

      token = JsonWebToken.encode(
        user_id: current_user.id,
        username: current_user.name,
        email: current_user.email
      )
      cookies[:cvt] = {
        value: token,
        secure: Rails.env.production?,
        same_site: :strict
      }
      @tauri_token = token
      render "users/sessions/tauri_callback", layout: false
    end

    def check_captcha
      return unless Flipper.enabled?(:recaptcha) && !verify_recaptcha
      self.resource = resource_class.new sign_in_params
      respond_with_navigational(resource) { render :new }
    end
end