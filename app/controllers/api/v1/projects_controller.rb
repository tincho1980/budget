class Api::V1::ProjectsController < Api::V1::BaseController
  def index
    @projects = current_client.projects.includes(:budgets).order(:name)
  end

  def show
    @project = current_client.projects.find(params[:id])
  end
end
