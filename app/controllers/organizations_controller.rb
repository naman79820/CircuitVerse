# frozen_string_literal: true

class OrganizationsController < ApplicationController
  before_action :authenticate_user!, except: %i[overview members check_slug]
  before_action :check_organizations_feature_flag
  before_action :set_organization, only: %i[show overview members settings update destroy]
  before_action :check_show_access, only: %i[show overview members settings]
  before_action :check_edit_access, only: %i[settings update destroy]

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
    @groups = @organization.groups.order(created_at: :desc)
                           .paginate(page: params[:groups_page], per_page: 9)
  end

# GET /organizations/1/members
  def members
    @active_tab = "members"
    @organization_members = @organization.organization_members.includes(:user).references(:user)

    # Name search
    if params[:q].present?
      @organization_members = @organization_members.where("users.name ILIKE ?", "%#{params[:q]}%")
    end

    # Column sorting: sort = name | role | joined, direction = asc | desc
    direction = params[:direction] == "asc" ? "asc" : "desc"

    @organization_members =
      case params[:sort]
      when "name"
        @organization_members.order(Arel.sql("users.name #{direction == 'asc' ? 'ASC' : 'DESC'}"))
      when "role"
        # Sort by role priority. desc = admin -> mentor -> member (high to low),
        # asc = member -> mentor -> admin. Uses the enum's stored integer values,
        # so it's independent of how the enum is declared.
        ordered = direction == "asc" ? %w[member mentor admin] : %w[admin mentor member]
        when_clauses = ordered.each_with_index.map do |name, i|
          "WHEN #{OrganizationMember.roles[name].to_i} THEN #{i}"
        end.join(" ")
        @organization_members.order(Arel.sql("CASE organization_members.role #{when_clauses} END"))
      when "joined"
        @organization_members.order(created_at: (direction == "asc" ? :asc : :desc))
      else
        # Default: newest members first
        @organization_members.order(created_at: :desc)
      end

    @organization_members = @organization_members.paginate(page: params[:page], per_page: 10)
  end

  # GET /organizations/1/settings  (renders the edit form; saves via #update)
  def settings
    @active_tab = "settings"
  end

  # GET /organizations/new
  def new
    @organization = Organization.new
  end

  # GET /organizations/check_slug
  def check_slug
    base_slug = params[:slug].presence || params[:name].to_s.strip.parameterize
    is_taken = base_slug.present? && Organization.exists?(slug: base_slug)

    render json: { slug: base_slug, available: base_slug.present? && !is_taken }
  end

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

  # PATCH/PUT /organizations/1  (settings form submits here)
  def update
    respond_to do |format|
      if @organization.update(organization_params)
        format.html { redirect_to settings_organization_path(@organization), notice: t(".success") }
        format.json { render :show, status: :ok, location: @organization }
      else
        @active_tab = "settings"
        format.html { render :settings, status: :unprocessable_content }
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