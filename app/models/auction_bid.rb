# == Schema Information
#
# Table name: auction_bids
#
#  id                      :bigint           not null, primary key
#  listing_id              :bigint
#  person_id               :string(255)
#  price_auction_bid_cents :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#
# Indexes
#
#  index_auction_bids_on_listing_id                (listing_id)
#  index_auction_bids_on_listing_id_and_person_id  (listing_id,person_id) UNIQUE
#  index_auction_bids_on_person_id                 (person_id)
#

class AuctionBid < ApplicationRecord
  belongs_to :listing, counter_cache: :auction_bids_count
  belongs_to :person

  validate :price_update_listing, on: :update

  monetize :price_auction_bid_cents, allow_nil: true, with_model_currency: :currency

  private

  def price_update_listing
    return if price_auction_bid_cents_changed? && price_auction_bid_cents > price_auction_bid_cents_was

    errors[:base] << "You can not reduce the price!"
  end
end
