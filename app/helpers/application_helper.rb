module ApplicationHelper
  def full_title(page_title)
    base_title = "再現Kitchen"
    if page_title.blank?
      base_title
    else
      "#{page_title} - #{base_title}"
    end
  end
end
