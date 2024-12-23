module FileHelper
  def image_file_path(filename)
    Rails.root.join("spec", "fixtures", "images", filename)
  end
end
