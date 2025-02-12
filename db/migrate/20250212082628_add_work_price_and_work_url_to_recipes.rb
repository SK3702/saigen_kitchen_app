class AddWorkPriceAndWorkUrlToRecipes < ActiveRecord::Migration[6.1]
  def change
    add_column :recipes, :work_price, :integer
    add_column :recipes, :work_url, :string
  end
end
