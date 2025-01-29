class AddImageAndTipToRecipes < ActiveRecord::Migration[6.1]
  def change
    add_column :recipes, :image, :string
    add_column :recipes, :tip, :text
  end
end
