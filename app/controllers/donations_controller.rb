class DonationsController < ApplicationController
  before_action :set_donation, only: [:show, :edit, :update, :destroy]

  # GET /donations
  # GET /donations.json
  def index
    @donations = Donation.all
  end

  # GET /donations/1
  # GET /donations/1.json
  def show
  end

  # GET /donations/new
  def new
    @donation = Donation.new
  end

  # GET /donations/1/edit
  def edit
  end

  # POST /donations
  # POST /donations.json
  def create
    @donation = Donation.new(donation_params)

    respond_to do |format|
      if @donation.save
        format.html { redirect_to generate_payment }
        format.json { render :show, status: :created, location: @donation }
      else
        format.html { render :new }
        format.json { render json: @donation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /donations/1
  # PATCH/PUT /donations/1.json
  def update
    respond_to do |format|
      if @donation.update(donation_params)
        format.html { redirect_to @donation, notice: 'Donation was successfully updated.' }
        format.json { render :show, status: :ok, location: @donation }
      else
        format.html { render :edit }
        format.json { render json: @donation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /donations/1
  # DELETE /donations/1.json
  def destroy
    @donation.destroy
    respond_to do |format|
      format.html { redirect_to donations_url, notice: 'Donation was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_donation
      @donation = Donation.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def donation_params
      params.require(:donation).permit(:name, :email, :amount)
    end

    def generate_payment

      # Keep in mind:
      # Amount is the total amount for the order
      # Amount has to be in cents
      # Each item should have it's unit price, not the subtotal for the line
      # Amount should be equal to the sum of unit prices * items amount
      
      amount = @donation.amount * 100

      response = EXPRESS_GATEWAY.setup_purchase(
        amount,
        ip: request.remote_ip,
        return_url: "#{request.protocol}#{request.host_with_port}/payments/success",
        cancel_return_url: "#{request.protocol}#{request.host_with_port}/payments/failure",
        currency: "USD",
        allow_guest_checkout: true,
        items: [
          {
            name: "Donation",
            description: "Donation",
            quantity: 1,
            amount: amount
          }]
      )

      @donation.update_attributes(payment_token: response.token)

      EXPRESS_GATEWAY.redirect_url_for(response.token)

    end
end
