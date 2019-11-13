class AddAuctionBidsCountToListings < ActiveRecord::Migration[5.2]
  def change
    add_column :listings, :auction_bids_count, :integer, default: 0
  end
end
