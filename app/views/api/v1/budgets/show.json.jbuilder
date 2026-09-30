# Only what the client agreed to pay: no hourly rates, costs, internal
# (non-billable) tasks or hours logged by the team.
billable_items = @budget.budget_items.select(&:billable)

json.budget do
  json.extract! @budget, :id, :version, :status, :sent_at, :approved_at, :notes
  json.total format("%.2f", @budget.total)
  json.project do
    json.extract! @budget.project, :id, :name
  end
  json.estimated_hours format("%.2f", billable_items.sum(&:estimated_hours))
  json.modules billable_items.group_by { |item| item.module_name.presence || "General" } do |(module_name, items)|
    json.name module_name
    json.items items do |item|
      json.description item.description
      json.estimated_hours format("%.2f", item.estimated_hours)
    end
  end
end
