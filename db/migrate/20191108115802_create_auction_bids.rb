class CreateAuctionBids < ActiveRecord::Migration[5.2]
  def change
    create_table :auction_bids do |t|
      t.references :listing
      t.references :person
      t.integer :price_auction_bid_cents

      t.timestamps
    end

    add_index :auction_bids, [:listing_id, :person_id], :unique => true
  end
end
