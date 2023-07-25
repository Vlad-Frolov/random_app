class MigratePicturesToPictureItems < ActiveRecord::Migration
  def up
    Picture.find_each do |picture|
      urls = picture.urls.split(',').concat([picture.first_pic])
      urls.each { |url| PictureItem.create!(user_id: picture.user_id, url: url) }
    end
  end

  def down
    # we need only users that have associated picture items + load picture items to avoid N+1 problem
    User.joins(:picture_items).includes(:picture_items).find_each do |user|
      urls = user.picture_items.map(&:url)
      first_pic = urls.shift
      Picture.create!(user_id: user.id, first_pic: first_pic, urls: urls.join(','))
    end
  end
end
