class Admin::TimeEntriesController < Admin::BaseController
  def index
    @time_entries = TimeEntry.includes(:user, budget_item: { budget: { project: :client } })
      .order(worked_on: :desc, id: :desc).limit(100)
  end

  def new
    @time_entry = TimeEntry.new(worked_on: Date.current, user: Current.user)
    load_task_options
  end

  def create
    @time_entry = TimeEntry.new(time_entry_params)
    # Developers log their own hours; an admin may log them for someone else.
    @time_entry.user = Current.user unless Current.user.role_admin? && @time_entry.user_id.present?

    if @time_entry.save
      redirect_to admin_time_entries_path, notice: "Horas registradas."
    else
      load_task_options
      render :new, status: :unprocessable_content
    end
  end

  def destroy
    TimeEntry.find(params[:id]).destroy!
    redirect_to admin_time_entries_path, notice: "Registro eliminado."
  end

  private

  # Hours are logged against approved budgets of projects that are still open,
  # grouped by project for the <select>.
  def load_task_options
    items = BudgetItem.joins(budget: :project).where(budgets: { status: :approved })
      .where.not(projects: { status: :closed }).includes(budget: :project).order("projects.name", :position)
    @task_options = items.group_by { |item| item.budget.project.name }
      .transform_values { |list| list.map { |item| [ item.description, item.id ] } }
  end

  def time_entry_params
    params.expect(time_entry: [ :budget_item_id, :user_id, :worked_on, :hours, :description ])
  end
end
