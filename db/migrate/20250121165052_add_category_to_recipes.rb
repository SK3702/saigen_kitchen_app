class AddCategoryToRecipes < ActiveRecord::Migration[6.1]
  def change
    unless column_exists?(:recipes, :category_id)
      add_reference :recipes, :category, null: true, foreign_key: true
    end
  end
end
