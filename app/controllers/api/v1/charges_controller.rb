class Api::V1::ChargesController < Api::V1::BaseController
  # GET /api/v1/charges?status=overdue
  def index
    @charges = current_client.maintenance_charges.includes(:payment_applications).order(due_on: :desc)

    if params[:status].present?
      unless MaintenanceCharge.statuses.key?(params[:status])
        return render_error(:bad_request, "Estado inválido. Valores posibles: #{MaintenanceCharge.statuses.keys.join(", ")}.")
      end

      @charges = @charges.where(status: params[:status])
    end
  end
end
