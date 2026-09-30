class Api::V1::AccountsController < Api::V1::BaseController
  def show
    @client = current_client
    @unpaid_charges = current_client.maintenance_charges.unpaid.includes(:payment_applications).order(:due_on)
    @recent_payments = current_client.payments.order(paid_on: :desc, id: :desc).limit(5)
  end
end
