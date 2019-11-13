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

require 'rails_helper'

RSpec.describe AuctionBidsController, type: :controller do

end
