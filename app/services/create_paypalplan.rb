class CreatePaypalplan
  def self.call(options={})

    # Plan definition
    plan = Plan.new({
      :name => 'eLucidaid License: Premium',
      :description => 'Annual plan',
      :type => 'INFINITE',
      :payment_definitions => [{
      :name => 'Premium Plan',
      :type => 'REGULAR',
      :frequency_interval => '1',
      :frequency => 'YEAR',
      :cycles => '0',
      :amount => {
        :currency => 'USD',
        :value => '149.99'
      }
    }],
    :merchant_preferences => {
      :setup_fee => {
        :currency => 'USD',
        :value => '1'
      },
      :cancel_url => 'http://localhost:3000/cancel',
      :return_url => 'http://localhost:3000/processagreement',
      :max_fail_attempts => '0',
      :auto_bill_amount => 'YES',
      :initial_fail_amount_action => 'CONTINUE'
    }
    })
end
end
