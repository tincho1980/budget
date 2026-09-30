# Back-office entry point: only team members (developers and admins) get in.
class Admin::BaseController < ApplicationController
  before_action :require_staff

  private

  def require_staff
    return if Current.user.staff?

    terminate_session
    redirect_to new_session_path, alert: "Tu usuario no tiene acceso al back-office."
  end
end
