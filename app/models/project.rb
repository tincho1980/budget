class Project < ApplicationRecord
  belongs_to :client
  has_many :budgets, dependent: :restrict_with_error
  has_one :maintenance_contract, dependent: :restrict_with_error
end
