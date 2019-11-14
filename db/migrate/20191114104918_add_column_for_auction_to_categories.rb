class AddColumnForAuctionToCategories < ActiveRecord::Migration[5.2]
  def change
    add_column :categories, :for_auction, :boolean, default: false, null: false
  end
end
