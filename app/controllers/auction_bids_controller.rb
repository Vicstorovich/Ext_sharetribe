class AuctionBidsController < ApplicationController
  def create
    auction_bid = listing.auction_bids.build
    auction_bid.assign_attributes(auction_bid_params)
    auction_bid.person_id = current_user.id
    auction_bid.save

    flash[:notice] = "You have safely raised the price"
    redirect_to listing
  end

  def update
    if auction_bid.update(auction_bid_params)
      flash[:notice] = "You have safely raised the price"
      redirect_to listing
    else
      flash[:error] = "You can not reduce the price!"
      redirect_to listing
    end
  end

  private

  def listing
    @listing ||= Listing.find(params[:listing_id])
  end

  def auction_bid
    @auction_bid ||= AuctionBid.find(params[:id])
  end
  helper_method :auction_bid

  def auction_bid_params
    params.require(:auction_bid).permit(:listing_id, :person_id, :price_auction_bid)
  end
end
