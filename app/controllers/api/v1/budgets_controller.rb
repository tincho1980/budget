class Api::V1::BudgetsController < Api::V1::BaseController
  before_action :set_budget

  def show
  end

  def approve
    decide(@budget.approve)
  end

  def reject
    decide(@budget.reject)
  end

  private

  # Drafts are internal, so they are not found for the client either.
  def set_budget
    @budget = current_client.budgets.visible_to_client.find(params[:id])
  end

  def decide(saved)
    if saved
      render :show
    else
      render_error(:unprocessable_content, "No se pudo registrar la decisión.", details: @budget.errors.full_messages)
    end
  end
end
