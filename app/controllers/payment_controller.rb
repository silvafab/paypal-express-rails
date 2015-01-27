class PaymentController < ApplicationController
  def success
    donation = Donation.find_by(payment_token: params[:token])

    details = EXPRESS_GATEWAY.details_for(donation.payment_token)

    express_purchase_options = {
      ip: request.remote_ip,
      token: donation.token,
      payer_id: details.payer_id
    }

    response = EXPRESS_GATEWAY.purchase(donation.amount * 100, express_purchase_options)

    if response.success?
      format.html { redirect_to donations_url, notice: 'Donation was successfully created and payed.' }
    end

  end

  def failure
    # Chaos!
  end
end
