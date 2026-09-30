class Admin::MaintenanceContractsController < Admin::BaseController
  before_action :set_contract, only: %i[ show edit update destroy generate_charge ]

  def index
    @contracts = MaintenanceContract.includes(:client, :project).order(:status, :starts_on)
  end

  def show
    @charges = @contract.maintenance_charges.includes(:payment_applications).order(period: :desc)
  end

  def new
    @contract = MaintenanceContract.new(client_id: params[:client_id], starts_on: Date.current.beginning_of_month, due_day: 10)
  end

  def create
    @contract = MaintenanceContract.new(contract_params)

    if @contract.save
      redirect_to admin_maintenance_contract_path(@contract), notice: "Contrato creado."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @contract.update(contract_params)
      redirect_to admin_maintenance_contract_path(@contract), notice: "Contrato actualizado."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    if @contract.destroy
      redirect_to admin_maintenance_contracts_path, notice: "Contrato eliminado."
    else
      redirect_to admin_maintenance_contract_path(@contract), alert: @contract.errors.full_messages.to_sentence
    end
  end

  def generate_charge
    charge = @contract.generate_charge_for(Date.current)

    if charge
      redirect_to admin_maintenance_contract_path(@contract), notice: "Cuota #{charge.period} lista (si ya existía, no se duplicó)."
    else
      redirect_to admin_maintenance_contract_path(@contract), alert: "Un contrato pausado o cancelado no genera cuotas nuevas."
    end
  end

  private

  def set_contract
    @contract = MaintenanceContract.find(params[:id])
  end

  def contract_params
    params.expect(maintenance_contract: [ :client_id, :project_id, :monthly_amount, :due_day, :starts_on, :ends_on, :status ])
  end
end
