# frozen_string_literal: true

class OrganizationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_organization, only: %i[show edit update destroy add_member remove_member update_role]
  before_action :check_show_access, only: [:show]
  before_action :check_admin_access, only: %i[edit update destroy add_member remove_member update_role]

  def index
    @organizations = current_user.organizations
  end

  def show
    @members = @organization.organization_members.includes(:user)
    @groups = @organization.groups.includes(:primary_mentor)
  end

  def new
    @organization = Organization.new
  end

  def create
    @organization = Organization.new(organization_params)

    if @organization.save
      # creator becomes the org admin automatically
      @organization.organization_members.create!(user: current_user, role: :admin)
      redirect_to @organization, notice: "Organization was successfully created."
    else
      render :new
    end
  end

  def edit; end

  def update
    if @organization.update(organization_params)
      redirect_to @organization, notice: "Organization was successfully updated."
    else
      render :edit
    end
  end

  def destroy
    @organization.destroy
    redirect_to organizations_path, notice: "Organization was successfully deleted."
  end

  def add_member
    email = params[:email]&.strip
    role = params[:role] || "member"
    user = User.find_by(email: email)

    unless user
      redirect_to @organization, alert: "No user found with that email."
      return
    end

    if @organization.member?(user)
      redirect_to @organization, alert: "User is already a member of this organization."
      return
    end

    @organization.organization_members.create!(user: user, role: role)
    redirect_to @organization, notice: "#{user.name} was added to the organization."
  end

  def remove_member
    membership = @organization.organization_members.find(params[:member_id])
    membership.destroy
    redirect_to @organization, notice: "Member was removed from the organization."
  end

  def update_role
    membership = @organization.organization_members.find(params[:member_id])
    membership.update!(role: params[:role])
    redirect_to @organization, notice: "Role updated successfully."
  end

  private

    def set_organization
      @organization = Organization.friendly.find(params[:id])
    end

    def organization_params
      params.require(:organization).permit(:name, :description, :oidc_client_id, :oidc_client_secret, :oidc_issuer)
    end

    def check_show_access
      authorize @organization, :show?
    end

    def check_admin_access
      authorize @organization, :admin_access?
    end
end
