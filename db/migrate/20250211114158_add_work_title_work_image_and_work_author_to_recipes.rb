class AddWorkTitleWorkImageAndWorkAuthorToRecipes < ActiveRecord::Migration[6.1]
  def change
    add_column :recipes, :work_title, :string
    add_column :recipes, :work_image, :string
    add_column :recipes, :work_author, :string
  end
end
