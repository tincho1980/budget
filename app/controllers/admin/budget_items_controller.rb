class Admin::BudgetItemsController < Admin::BaseController
  before_action :set_budget, only: %i[ new create ]
  before_action :set_item, only: %i[ edit update destroy ]

  def new
    @item = @budget.budget_items.new(billable: true, position: @budget.budget_items.count)
  end

  def create
    @item = @budget.budget_items.new(item_params)

    if @item.save
      redirect_to admin_budget_path(@budget), notice: "Ítem agregado."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @item.update(item_params)
      redirect_to admin_budget_path(@item.budget), notice: "Ítem actualizado."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    if @item.destroy
      redirect_to admin_budget_path(@item.budget), notice: "Ítem eliminado."
    else
      redirect_to admin_budget_path(@item.budget), alert: @item.errors.full_messages.to_sentence
    end
  end

  private

  def set_budget
    @budget = Budget.find(params[:budget_id])
  end

  def set_item
    @item = BudgetItem.find(params[:id])
  end

  def item_params
    params.expect(budget_item: [ :module_name, :description, :estimated_hours, :level, :billable, :position ])
  end
end
