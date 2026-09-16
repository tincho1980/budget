# Seniority shared by users, rates and budget items.
# Rates are looked up by level, so the three models must use the same values.
module SeniorityLevel
  extend ActiveSupport::Concern

  LEVELS = { junior: 0, semi: 1, senior: 2 }.freeze

  included do
    enum :level, LEVELS
  end
end
