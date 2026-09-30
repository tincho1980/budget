class Admin::ClientsController < Admin::BaseController
  before_action :set_client, only: %i[ show edit update destroy ]

  def index
    @clients = Client.order(:business_name)
  end

  def show
    @projects = @client.projects.order(:name)
    @contracts = @client.maintenance_contracts.order(:starts_on)
    @users = @client.users.order(:name)
    @payments = @client.payments.order(paid_on: :desc).limit(10)
  end

  def new
    @client = Client.new
  end

  def create
    @client = Client.new(client_params)

    if @client.save
      redirect_to admin_client_path(@client), notice: "Cliente creado."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @client.update(client_params)
      redirect_to admin_client_path(@client), notice: "Cliente actualizado."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    if @client.destroy
      redirect_to admin_clients_path, notice: "Cliente eliminado."
    else
      redirect_to admin_client_path(@client), alert: @client.errors.full_messages.to_sentence
    end
  end

  private

  def set_client
    @client = Client.find(params[:id])
  end

  def client_params
    params.expect(client: [ :business_name, :contact_name, :email, :tax_id, :phone, :active ])
  end
end
