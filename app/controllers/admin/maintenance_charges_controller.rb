class Admin::MaintenanceChargesController < Admin::BaseController
  def index
    @charges = MaintenanceCharge.includes(:payment_applications, maintenance_contract: :client)
      .order(due_on: :desc)
    @charges = @charges.where(status: params[:status]) if MaintenanceCharge.statuses.key?(params[:status])
  end
end
