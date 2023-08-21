# frozen_string_literal: true

class PictureItem < ActiveRecord::Base
  belongs_to :user

  validates :user_id, :url, presence: true
  validates :url, uniqueness: { scope: :user_id }
end
