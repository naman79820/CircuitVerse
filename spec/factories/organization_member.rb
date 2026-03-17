# frozen_string_literal: true

FactoryBot.define do
  factory :organization_member do
    association :organization
    association :user
    role { :member }

    trait :admin do
      role { :admin }
    end

    trait :group_lead do
      role { :group_lead }
    end

    trait :instructor do
      role { :instructor }
    end
  end
end
