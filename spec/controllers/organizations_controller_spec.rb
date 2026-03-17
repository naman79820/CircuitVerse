# frozen_string_literal: true

require "rails_helper"

describe OrganizationsController, type: :request do
  before do
    @org_admin = FactoryBot.create(:user)
    @member = FactoryBot.create(:user)
    @org = FactoryBot.create(:organization)
    FactoryBot.create(:organization_member, organization: @org, user: @org_admin, role: :admin)
    FactoryBot.create(:organization_member, organization: @org, user: @member, role: :member)
  end

  describe "#index" do
    it "renders page for logged in user" do
      sign_in @org_admin
      get organizations_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#create" do
    it "creates an organization" do
      sign_in @org_admin
      expect do
        post organizations_path, params: { organization: { name: "Test University" } }
      end.to change(Organization, :count).by(1)
    end

    it "makes the creator an org admin" do
      sign_in @org_admin
      post organizations_path, params: { organization: { name: "New Org" } }
      org = Organization.last
      expect(org.admin?(@org_admin)).to be true
    end
  end

  describe "#show" do
    context "when a member is signed in" do
      it "shows the organization" do
        sign_in @member
        get organization_path(@org)
        expect(response).to have_http_status(:ok)
      end
    end

    context "when a random user is signed in" do
      it "throws not authorized error" do
        sign_in_random_user
        get organization_path(@org)
        check_not_authorized(response)
      end
    end
  end

  describe "#update" do
    context "when org admin is signed in" do
      it "updates organization" do
        sign_in @org_admin
        patch organization_path(@org), params: { organization: { name: "Updated" } }
        @org.reload
        expect(@org.name).to eq("Updated")
      end
    end

    context "when a regular member is signed in" do
      it "throws not authorized error" do
        sign_in @member
        patch organization_path(@org), params: { organization: { name: "Nope" } }
        check_not_authorized(response)
      end
    end
  end

  describe "#destroy" do
    context "when org admin is signed in" do
      it "destroys organization" do
        sign_in @org_admin
        expect do
          delete organization_path(@org)
        end.to change(Organization, :count).by(-1)
      end
    end

    context "when a regular member is signed in" do
      it "throws not authorized error" do
        sign_in @member
        delete organization_path(@org)
        check_not_authorized(response)
      end
    end
  end

  describe "#add_member" do
    context "when org admin adds a user" do
      it "adds the member" do
        new_user = FactoryBot.create(:user)
        sign_in @org_admin
        expect do
          post add_member_organization_path(@org), params: { email: new_user.email, role: "instructor" }
        end.to change(OrganizationMember, :count).by(1)
      end
    end

    context "when a non-admin tries" do
      it "throws not authorized error" do
        sign_in @member
        post add_member_organization_path(@org), params: { email: "test@example.com", role: "member" }
        check_not_authorized(response)
      end
    end
  end

  describe "#remove_member" do
    context "when org admin removes someone" do
      it "removes the member" do
        sign_in @org_admin
        record = @org.organization_members.find_by(user: @member)
        expect do
          delete remove_member_organization_path(@org), params: { member_id: record.id }
        end.to change(OrganizationMember, :count).by(-1)
      end
    end
  end

  describe "#update_role" do
    it "changes role for a member" do
      sign_in @org_admin
      record = @org.organization_members.find_by(user: @member)
      patch update_role_organization_path(@org), params: { member_id: record.id, role: "instructor" }
      record.reload
      expect(record.role).to eq("instructor")
    end
  end
end
