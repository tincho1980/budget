budget = project.budgets.select { |b| !b.draft? }.max_by(&:version)

json.extract! project, :id, :name, :description, :status, :started_on, :closed_on
json.current_budget do
  if budget
    json.id budget.id
    json.version budget.version
    json.status budget.status
    json.total format("%.2f", budget.total)
    json.pending_approval budget.sent?
  else
    json.nil!
  end
end
