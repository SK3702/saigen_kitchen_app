class RenameImageColumnToRecipes < ActiveRecord::Migration[6.1]
  def change
    rename_column :recipes, :image, :recipe_image
  end
end
