# frozen_string_literal: true

class Picture < ActiveRecord::Base
  validates_uniqueness_of :user_id
  validates :user_id, :first_pic, presence: true
end
