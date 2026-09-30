# Rates are never edited: a new value is a new row with its own valid_from,
# so budgets already issued keep the rate they were priced with (rule 2).
class Admin::RatesController < Admin::BaseController
  def index
    @rates = Rate.order(:level, valid_from: :desc)
    @current_rates = Rate.levels.keys.index_with { |level| Rate.current_for(level) }
  end

  def new
    @rate = Rate.new(valid_from: Date.current)
  end

  def create
    @rate = Rate.new(rate_params)

    if @rate.save
      redirect_to admin_rates_path, notice: "Tarifa creada."
    else
      render :new, status: :unprocessable_content
    end
  end

  private

  def rate_params
    params.expect(rate: [ :level, :hourly_value, :valid_from ])
  end
end
