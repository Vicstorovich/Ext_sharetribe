class AuctionBidsController < ApplicationController

  def create
    auction_bid = listing.auction_bids.build
    auction_bid.assign_attributes(auction_bid_params)
    auction_bid.person = current_user
# binding.pry
    if auction_bid.save

      flash[:notice] = "You have safely raised the price OK"
      redirect_to listing
    else
      flash[:notice] = "NIZЯ"
      redirect_to listing
    end
  end

  private

  def listing
    @listing ||= Listing.find(params[:listing_id])
  end
  helper_method :listing

  def auction_bid_params
    params.require(:auction_bid).permit(:listing_id, :person_id, :price_auction_bid)
  end
end
