# frozen_string_literal: true

class Api::V1::OrganizationsController < Api::V1::BaseController
  before_action :authenticate_user!
  before_action :set_organization, only: %i[show update destroy]
  before_action :check_show_access, only: [:show]
  before_action :check_admin_access, only: %i[update destroy]

  def index
    @organizations = paginate(current_user.organizations)
    options = { params: { current_user: current_user } }
    options[:links] = link_attrs(@organizations, api_v1_organizations_url)
    render json: Api::V1::OrganizationSerializer.new(@organizations, options)
  end

  def show
    render json: Api::V1::OrganizationSerializer.new(@organization)
  end

  def create
    @organization = Organization.new(organization_params)
    if @organization.save
      @organization.organization_members.create!(user: current_user, role: :admin)
      render json: Api::V1::OrganizationSerializer.new(@organization), status: :created
    else
      invalid_resource!(@organization.errors)
    end
  end

  def update
    if @organization.update(organization_params)
      render json: Api::V1::OrganizationSerializer.new(@organization), status: :accepted
    else
      invalid_resource!(@organization.errors)
    end
  end

  def destroy
    @organization.destroy!
    head :no_content
  end

  private

    def set_organization
      @organization = Organization.friendly.find(params[:id])
    end

    def organization_params
      params.require(:organization).permit(:name, :description)
    end

    def check_show_access
      authorize @organization, :show?
    end

    def check_admin_access
      authorize @organization, :admin_access?
    end
end
