# == Schema Information
#
# Table name: listings
#
#  id                              :integer          not null, primary key
#  uuid                            :binary(16)       not null
#  community_id                    :integer          not null
#  author_id                       :string(255)
#  category_old                    :string(255)
#  title                           :string(255)
#  times_viewed                    :integer          default(0)
#  language                        :string(255)
#  created_at                      :datetime
#  updates_email_at                :datetime
#  updated_at                      :datetime
#  last_modified                   :datetime
#  sort_date                       :datetime
#  listing_type_old                :string(255)
#  description                     :text(65535)
#  origin                          :string(255)
#  destination                     :string(255)
#  valid_until                     :datetime
#  delta                           :boolean          default(TRUE), not null
#  open                            :boolean          default(TRUE)
#  share_type_old                  :string(255)
#  privacy                         :string(255)      default("private")
#  comments_count                  :integer          default(0)
#  subcategory_old                 :string(255)
#  old_category_id                 :integer
#  category_id                     :integer
#  share_type_id                   :integer
#  listing_shape_id                :integer
#  transaction_process_id          :integer
#  shape_name_tr_key               :string(255)
#  action_button_tr_key            :string(255)
#  price_cents                     :integer
#  currency                        :string(255)
#  quantity                        :string(255)
#  unit_type                       :string(32)
#  quantity_selector               :string(32)
#  unit_tr_key                     :string(64)
#  unit_selector_tr_key            :string(64)
#  deleted                         :boolean          default(FALSE)
#  require_shipping_address        :boolean          default(FALSE)
#  pickup_enabled                  :boolean          default(FALSE)
#  shipping_price_cents            :integer
#  shipping_price_additional_cents :integer
#  availability                    :string(32)       default("none")
#  per_hour_ready                  :boolean          default(FALSE)
#  state                           :string(255)      default("approved")
#  auction_bids_count              :integer          default(0)
#
# Indexes
#
#  community_author_deleted            (community_id,author_id,deleted)
#  index_listings_on_category_id       (old_category_id)
#  index_listings_on_community_id      (community_id)
#  index_listings_on_listing_shape_id  (listing_shape_id)
#  index_listings_on_new_category_id   (category_id)
#  index_listings_on_open              (open)
#  index_listings_on_state             (state)
#  index_listings_on_uuid              (uuid) UNIQUE
#  index_on_author_id_and_deleted      (author_id,deleted)
#  listings_homepage_query             (community_id,open,state,deleted,valid_until,sort_date)
#  listings_updates_email              (community_id,open,state,deleted,valid_until,updates_email_at,created_at)
#  person_listings                     (community_id,author_id)
#

require 'spec_helper'

describe Listing, type: :model do

  before(:each) do
    @listing = FactoryGirl.build(:listing, listing_shape_id: 123)
  end

  it "is valid with valid attributes" do
    expect(@listing).to be_valid
  end

  it "is not valid without a title" do
    @listing.title = nil
    expect(@listing).not_to be_valid
  end

  it "is not valid with a too short title" do
    @listing.title = "a"
    expect(@listing).not_to be_valid
  end

  it "is not valid with a too long title" do
    @listing.title = "0" * 101
    expect(@listing).not_to be_valid
  end

  it "is valid without a description" do
    @listing.description = nil
    expect(@listing).to be_valid
  end

  it "is not valid if description is longer than 5000 characters" do
    @listing.description = "0" * 5001
    expect(@listing).not_to be_valid
  end

  it "is not valid without an author" do
    @listing.author = nil
    expect(@listing).not_to be_valid
  end

  it "is not valid without category" do
    @listing.category = nil
    expect(@listing).not_to be_valid
  end

  it "should not be valid when valid until date is before current date" do
    @listing.valid_until = DateTime.now - 1.day - 1.minute
    expect(@listing).not_to be_valid
  end

  it "should not be valid when valid until is more than one year after current time" do
    @listing.valid_until = DateTime.now + 1.year + 2.days
    expect(@listing).not_to be_valid
  end

  context "with listing type 'offer'" do

    it "should be valid when there is no valid until" do
      @listing.valid_until = nil
      expect(@listing).to be_valid
    end

  end

  context 'manage availability per hour' do
    let(:community) { FactoryGirl.create(:community) }
    let(:listing) { FactoryGirl.create(:listing, community_id: community.id, listing_shape_id: 123) }

    it '#working_hours_periods_grouped_by_day' do
      listing.working_hours_new_set
      listing.save
      periods = listing.working_hours_periods_grouped_by_day(Time.zone.parse('2017-11-13'), Time.zone.parse('2017-11-19'))
      expect(periods.keys).to eq ["2017-11-13", "2017-11-14", "2017-11-15", "2017-11-16", "2017-11-17"]
      ["2017-11-13", "2017-11-14", "2017-11-15", "2017-11-16", "2017-11-17"].each do |date|
        expect(periods[date].first.start_time.to_s).to eq "#{date} 09:00:00 UTC"
        expect(periods[date].first.end_time.to_s).to eq "#{date} 17:00:00 UTC"
      end
    end
  end

  describe "delete_listings" do
    let(:location) { FactoryGirl.create(:location) }
    let(:hammer) { FactoryGirl.create(:listing, title: "Hammer", listing_shape_id: 123, location: location)}
    let(:author) { hammer.author }

    it "delete_listings by author" do
      # Guard
      expect(hammer.deleted?).to eq(false)

      Listing.delete_by_author(author.id)
      hammer.reload

      expect(hammer.description).to be_nil
      expect(hammer.origin).to be_nil
      expect(hammer.open).to be false
      expect(hammer.location).to be_nil
      expect(hammer.deleted?).to be true
    end
  end

  describe "methods for template show from association auction_bid" do
    let!(:person_1) { FactoryGirl.create(:person) }
    let!(:person_2) { FactoryGirl.create(:person) }
    let!(:category_1) { FactoryGirl.create(:category, for_auction: true) }
    let!(:category_2) { FactoryGirl.create(:category, for_auction: false) }
    let!(:listing) { FactoryGirl.create(:listing, price_cents: 1) }
    let!(:listing_not_auction_bids) { FactoryGirl.create(:listing, price_cents: 2) }
    let!(:auction_bid_first) do
       FactoryGirl.create(:auction_bid, listing_id: listing.id, person_id: person_1.id, price_auction_bid_cents: 15)
    end
    let!(:auction_bid_last) do
       FactoryGirl.create(:auction_bid, listing_id: listing.id, person_id: person_2.id, price_auction_bid_cents: 17)
    end

    context "method person_leader_auction?" do
      it "person_leader_auction?" do
        expect(listing.auction_bids.maximum(:price_auction_bid_cents)).to eq(person_2.auction_bids.last.price_auction_bid_cents)
        expect(listing.auction_bids.maximum(:price_auction_bid_cents) == person_2.auction_bids.last.price_auction_bid_cents).to eq true
      end

      it "person_not_leader_auction?" do
        expect(listing.auction_bids.maximum(:price_auction_bid_cents)).to_not eq(person_1.auction_bids.last.price_auction_bid_cents)
        expect(listing.auction_bids.maximum(:price_auction_bid_cents) == person_1.auction_bids.last.price_auction_bid_cents).to eq false
      end
    end

    context "method auction_winner?" do
      it "person auction winner" do
        expect(listing.valid_until.ago(23.hour) == Time.zone.now && listing.person_leader_auction?(person_1)).to_not eq true
      end
    end

    context "method auction_start?" do
      it "category declared as auction" do
        expect(listing.valid_until.ago(23.hour) != Time.zone.now && category_1.for_auction == true).to_not eq false
      end

      it "category not listed as an auction" do
        expect(listing.valid_until.ago(23.hour) != Time.zone.now && category_2.for_auction == true).to_not eq true
      end
    end

    context "method maximum_contract_price" do
      it "listing_auction_has_bids" do
        expect(listing.auction_bids.exists?).to eq true
        expect(listing.auction_bids.where(price_auction_bid_cents: listing.auction_bids.maximum(:price_auction_bid_cents))[0]).to eq(auction_bid_last)
      end

      it "listing_auction_not_bids" do
        expect(listing_not_auction_bids.auction_bids.exists?).to eq false
      end
    end
  end
end
