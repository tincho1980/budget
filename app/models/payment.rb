class Payment < ApplicationRecord
  belongs_to :client
  belongs_to :registered_by
end
