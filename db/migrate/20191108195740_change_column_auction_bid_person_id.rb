class ChangeColumnAuctionBidPersonId < ActiveRecord::Migration[5.2]
  def up
    change_column :auction_bids, :person_id, :string
  end

  def down
    change_column :auction_bids, :person_id, :integer
  end
end
