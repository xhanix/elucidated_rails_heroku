class AddTrialPeriodDaysToPlans < ActiveRecord::Migration[5.0]
  def change
    add_column :plans, :trial_period_days, :integer
  end
end
