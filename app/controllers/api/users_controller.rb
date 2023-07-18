# frozen_string_literal: true

module Api
  class UsersController < ApplicationController
    def index
      users = User.includes(picture_entity_key).all
      resp = users.map { |user| user_response(user) }
      render json: resp
    end

    def update
      user = User.find(params[:id])
      update_picture(user)

      render json: user_response(user, pictures_param_name: :pictures)
    rescue ActiveRecord::ActiveRecordError => e
      render json: { error: e.message }, status: :bad_request
    end

    private

    def picture_entity_key
      raise NotImplementedError, 'Your subclass  must implement it'
    end

    def update_picture
      raise NotImplementedError, 'Your subclass  must implement it'
    end

    def user_response
      raise NotImplementedError, 'Your subclass  must implement it'
    end
  end
end
