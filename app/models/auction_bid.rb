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
#  index_auction_bids_on_listing_id_and_person_id  (listing_id,person_id)
#  index_auction_bids_on_person_id                 (person_id)
#

class AuctionBid < ApplicationRecord
  belongs_to :listing, counter_cache: :auction_bids_count, inverse_of: :auction_bids
  belongs_to :person

  validates :price_auction_bid_cents, numericality: {greater_than_or_equal_to: 0.01}

  validate :prohibition_lower_auction_bid

  monetize :price_auction_bid_cents, allow_nil: true, with_model_currency: :currency

  private

  def prohibition_lower_auction_bid
    unless listing.auction_bids.maximum(:price_auction_bid_cents).nil?
      return if listing.auction_bids.maximum(:price_auction_bid_cents) < price_auction_bid_cents
    else
      return if listing.price_cents < price_auction_bid_cents
    end

    errors.add :price_auction_bid
  end
end
