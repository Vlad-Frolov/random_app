# frozen_string_literal: true

class PictureUpdater
  def self.call(user, picture_params, urls)
    ActiveRecord::Base.transaction do
      user.picture ? user.picture.update!(picture_params) : user.create_picture!(picture_params)
      PictureItemSynchronizer.call(user, urls)
    end
  end
end
