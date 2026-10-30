class Api::V1::PaymentsController < Api::V1::BaseController
  def index
    @payments = current_client.payments.with_attached_receipt.order(paid_on: :desc, id: :desc)
  end

  # Rule 17: a payment reported by the client stays in review and is not
  # applied to any charge until an admin confirms it in the back-office.
  def create
    @payment = current_client.payments.new(payment_params)
    @payment.registered_by = current_user
    @payment.status = :pending_review
    @payment.save!

    render :show, status: :created
  end

  private

  # JSON bodies arrive wrapped in "payment" (wrap_parameters). A multipart
  # upload with the receipt sends the fields at the top level, so both work.
  def payment_params
    attributes = params.key?(:payment) ? params.require(:payment) : params
    attributes.permit(:amount, :paid_on, :payment_method, :notes, :receipt)
  end
end
