class Admin::UsersController < Admin::BaseController
  before_action :require_admin
  before_action :set_user, only: %i[ edit update ]

  def index
    @users = User.includes(:client).order(role: :desc, name: :asc)
  end

  def new
    @user = User.new(client_id: params[:client_id], role: (params[:client_id] ? :client : :developer))
  end

  def create
    @user = User.new(user_params)

    if @user.save
      redirect_to admin_users_path, notice: "Usuario creado."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    attributes = user_params
    attributes = attributes.except(:password, :password_confirmation) if attributes[:password].blank?

    if @user.update(attributes)
      redirect_to admin_users_path, notice: "Usuario actualizado."
    else
      render :edit, status: :unprocessable_content
    end
  end

  private

  def require_admin
    redirect_to admin_root_path, alert: "Sólo un administrador puede gestionar usuarios." unless Current.user.role_admin?
  end

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.expect(user: [ :name, :email_address, :password, :password_confirmation, :role, :level, :client_id ])
  end
end
