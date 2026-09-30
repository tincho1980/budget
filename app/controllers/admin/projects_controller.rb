class Admin::ProjectsController < Admin::BaseController
  before_action :set_project, only: %i[ show edit update destroy ]

  def index
    @projects = Project.includes(:client).order(:name)
    @projects = @projects.where(status: params[:status]) if Project.statuses.key?(params[:status])
  end

  def show
    @budgets = @project.budgets.order(:version)
    @approved_budget = @project.approved_budget
  end

  def new
    @project = Project.new(client_id: params[:client_id], started_on: Date.current)
  end

  def create
    @project = Project.new(project_params)

    if @project.save
      redirect_to admin_project_path(@project), notice: "Proyecto creado."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @project.update(project_params)
      redirect_to admin_project_path(@project), notice: "Proyecto actualizado."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    if @project.destroy
      redirect_to admin_projects_path, notice: "Proyecto eliminado."
    else
      redirect_to admin_project_path(@project), alert: @project.errors.full_messages.to_sentence
    end
  end

  private

  def set_project
    @project = Project.find(params[:id])
  end

  def project_params
    params.expect(project: [ :client_id, :name, :description, :status, :started_on, :closed_on ])
  end
end
