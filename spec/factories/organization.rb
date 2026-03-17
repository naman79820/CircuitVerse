# frozen_string_literal: true

FactoryBot.define do
  factory :organization do
    name { Faker::Company.name }
    description { Faker::Lorem.sentence }
  end
end
