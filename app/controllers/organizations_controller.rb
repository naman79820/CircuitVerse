# frozen_string_literal: true

class OrganizationsController < ApplicationController
  before_action :authenticate_user!, except: %i[overview members check_slug]
  before_action :check_organizations_feature_flag
  before_action :set_organization, only: %i[show overview members settings edit update destroy]
  before_action :check_show_access, only: %i[show overview members]
  before_action :check_edit_access, only: %i[settings edit update destroy]

  # GET /organizations
  def index
    @organizations = if params[:explore].present?
      Organization.where(private: false).order(created_at: :desc).paginate(page: params[:page], per_page: 9)
    else
      current_user.organizations.order(created_at: :desc).paginate(page: params[:page], per_page: 9)
    end
  end

  # GET /organizations/1  → redirect to overview tab
  def show
    redirect_to overview_organization_path(@organization)
  end

  # GET /organizations/1/overview
  def overview
    @active_tab = "overview"
    @groups = @organization.groups
                           .left_joins(:group_members)
                           .select("groups.*, COUNT(group_members.id) AS group_members_count")
                           .group("groups.id")
                           .order(created_at: :desc)
                           .paginate(page: params[:groups_page], per_page: 9, total_entries: @organization.groups.count)
  end

  # GET /organizations/1/members
  def members
    @active_tab = "members"
    members = @organization.organization_members.includes(:user).references(:user)
    members = search_members(members)
    members = sort_members(members)
    @organization_members = members.paginate(page: params[:page], per_page: 10)
  end

  # GET /organizations/1/settings
  # (settings tab content is added in a follow-up PR)
  def settings
    @active_tab = "settings"
  end

  # GET /organizations/new
  def new
    @organization = Organization.new
  end

  # GET /organizations/check_slug
  def check_slug
    base_slug = (params[:slug].presence || params[:name]).to_s.strip.parameterize
    is_taken = base_slug.present? && Organization.exists?(slug: base_slug)

    render json: { slug: base_slug, available: base_slug.present? && !is_taken }
  end

  # GET /organizations/1/edit
  def edit; end

  # POST /organizations
  def create
    @organization = Organization.new(organization_params)

    respond_to do |format|
      if create_organization
        format.html { redirect_to @organization, notice: t(".success") }
        format.json { render :show, status: :created, location: @organization }
      else
        flash.now[:alert] = t(".failure")
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @organization.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /organizations/1
  def update
    respond_to do |format|
      if @organization.update(organization_params)
        format.html { redirect_to @organization, notice: t(".success") }
        format.json { render :show, status: :ok, location: @organization }
      else
        format.html { render :edit }
        format.json { render json: @organization.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /organizations/1
  def destroy
    @organization.destroy
    respond_to do |format|
      format.html { redirect_to organizations_path, notice: t(".success") }
      format.json { head :no_content }
    end
  end

  private

    def set_organization
      @organization = Organization.friendly.find(params.expect(:id))
    end

    def organization_params
      params.expect(organization: [:name, :slug, :description, :location, :private, :logo, :remove_logo, { links: [] }])
    end

    def check_organizations_feature_flag
      return if Flipper.enabled?(:organizations, current_user)

      redirect_to root_path, alert: t("feature_not_available")
    end

    def check_show_access
      authorize @organization, :show_access?
    end

    def check_edit_access
      authorize @organization, :admin_access?
    end

    def search_members(scope)
      return scope if params[:q].blank?

      scope.where("users.name ILIKE ?", "%#{params[:q]}%")
    end

    def sort_members(scope)
      ascending = params[:direction] == "asc"

      case params[:sort]
      when "name"
        scope.order(Arel.sql("users.name #{ascending ? 'ASC' : 'DESC'}"))
      when "role"
        scope.order(Arel.sql(role_priority_sql(ascending)))
      when "joined"
        scope.order(created_at: (ascending ? :asc : :desc))
      else
        scope.order(created_at: :desc)
      end
    end

    def role_priority_sql(ascending)
      ordered = ascending ? %w[member mentor admin] : %w[admin mentor member]
      when_clauses = ordered.each_with_index.map do |name, i|
        "WHEN #{OrganizationMember.roles[name].to_i} THEN #{i}"
      end.join(" ")

      "CASE organization_members.role #{when_clauses} END"
    end

    def create_organization
      ActiveRecord::Base.transaction do
        if @organization.save
          @organization.organization_members.create!(user: current_user, role: :admin)
          true
        else
          false
        end
      rescue ActiveRecord::RecordInvalid => e
        @organization.errors.add(:base, e.message)
        raise ActiveRecord::Rollback
      end
    end
end
