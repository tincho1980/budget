class Api::V1::PaymentsController < Api::V1::BaseController
  def index
    @payments = current_client.payments.order(paid_on: :desc, id: :desc)
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

  def payment_params
    params.expect(payment: [ :amount, :paid_on, :payment_method, :notes ])
  end
end
