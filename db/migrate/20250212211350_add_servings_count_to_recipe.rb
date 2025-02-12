class AddServingsCountToRecipe < ActiveRecord::Migration[6.1]
  def change
    add_column :recipes, :servings_count, :integer
  end
end
