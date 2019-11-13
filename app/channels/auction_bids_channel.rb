class AuctionBidsChannel < ApplicationCable::Channel
  def follow
    stream_from 'auction_bids'
  end
end
