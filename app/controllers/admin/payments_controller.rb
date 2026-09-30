class Admin::PaymentsController < Admin::BaseController
  before_action :set_payment, only: %i[ show confirm reject ]

  def index
    @in_review = Payment.pending_review.includes(:client, :registered_by).order(:paid_on)
    @payments = Payment.where.not(status: :pending_review).includes(:client, :registered_by)
      .order(paid_on: :desc, id: :desc).limit(100)
  end

  def show
    @applications = @payment.payment_applications.includes(:maintenance_charge).order("maintenance_charges.due_on")
  end

  def new
    @payment = Payment.new(client_id: params[:client_id], paid_on: Date.current, payment_method: :transfer)
  end

  # Payments registered by the team are confirmed on the spot and applied to
  # the client's oldest unpaid charges.
  def create
    @payment = Payment.new(payment_params.merge(registered_by: Current.user, status: :confirmed))

    if @payment.valid?
      Payment.transaction do
        @payment.save!
        @payment.apply_to_open_charges!
      end
      redirect_to admin_payment_path(@payment), notice: "Pago registrado e imputado."
    else
      render :new, status: :unprocessable_content
    end
  end

  def confirm
    return redirect_to(admin_payment_path(@payment), alert: "El pago ya fue revisado.") unless @payment.pending_review?

    @payment.confirm!
    redirect_to admin_payment_path(@payment), notice: "Pago confirmado e imputado a las cuotas más antiguas."
  end

  def reject
    return redirect_to(admin_payment_path(@payment), alert: "El pago ya fue revisado.") unless @payment.pending_review?

    @payment.reject!
    redirect_to admin_payment_path(@payment), notice: "Pago rechazado."
  end

  private

  def set_payment
    @payment = Payment.find(params[:id])
  end

  def payment_params
    params.expect(payment: [ :client_id, :paid_on, :amount, :payment_method, :notes ])
  end
end
