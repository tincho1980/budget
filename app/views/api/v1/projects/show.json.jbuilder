json.project do
  json.partial! "api/v1/projects/project", project: @project
  json.budgets @project.budgets.visible_to_client.order(:version) do |budget|
    json.extract! budget, :id, :version, :status
    json.total format("%.2f", budget.total)
  end
end
