class Admin::BudgetsController < Admin::BaseController
  before_action :set_project, only: %i[ new create ]
  before_action :set_budget, except: %i[ new create ]
  before_action :require_draft, only: %i[ edit update destroy ]

  def show
    @items = @budget.budget_items.includes(:rate, :time_entries)
  end

  def new
    @budget = @project.budgets.new(version: @project.next_budget_version, buffer_percentage: 15)
  end

  def create
    @budget = @project.budgets.new(budget_params.merge(version: @project.next_budget_version))

    if @budget.save
      redirect_to admin_budget_path(@budget), notice: "Presupuesto creado. Ahora cargá sus ítems."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @budget.update(budget_params)
      redirect_to admin_budget_path(@budget), notice: "Presupuesto actualizado."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    project = @budget.project
    @budget.destroy!
    redirect_to admin_project_path(project), notice: "Borrador eliminado."
  end

  def send_to_client
    if @budget.send_to_client
      redirect_to admin_budget_path(@budget), notice: "Presupuesto enviado al cliente."
    else
      redirect_to admin_budget_path(@budget), alert: @budget.errors.full_messages.to_sentence
    end
  end

  # Rule 4: an issued budget is never edited; changes go into a copy as a new draft.
  def new_version
    copy = @budget.project.budgets.create!(
      version: @budget.project.next_budget_version,
      buffer_percentage: @budget.buffer_percentage,
      notes: @budget.notes
    )
    @budget.budget_items.each do |item|
      copy.budget_items.create!(item.slice(:module_name, :description, :estimated_hours, :level, :billable, :position))
    end
    redirect_to admin_budget_path(copy), notice: "Se creó la versión #{copy.version} como borrador, con las tarifas vigentes."
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_budget
    @budget = Budget.find(params[:id])
  end

  def require_draft
    return if @budget.draft?

    redirect_to admin_budget_path(@budget), alert: "Sólo se pueden modificar presupuestos en borrador."
  end

  def budget_params
    params.expect(budget: [ :buffer_percentage, :notes ])
  end
end
