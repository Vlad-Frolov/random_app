# frozen_string_literal: true

class PictureItemSynchronizer
  def self.call(user, urls)
    new(user, urls).call
  end

  def initialize(user, urls)
    @user = user
    @urls = urls
  end

  def call
    existing_urls = user.picture_items.pluck(:url)
    urls_to_add = urls - existing_urls
    urls_to_remove = existing_urls - urls

    PictureItem.transaction do
      user.picture_items.where(url: urls_to_remove).delete_all
      create_picture_items(urls_to_add) if urls_to_add.present? # from Rails 6 we could use bulk_insert
    end
  end

  private

  attr_reader :user, :urls

  def create_picture_items(urls)
    urls.each { |url| @user.picture_items.create!(url: url) }
  end
end
