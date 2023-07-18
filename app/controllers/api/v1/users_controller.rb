# frozen_string_literal: true

module Api
  module V1
    class UsersController < ::Api::UsersController
      private

      def picture_entity_key
        :picture
      end

      def update_picture(user)
        picture_params = { first_pic: params[:first_pic], urls: params[:urls]&.join(',') }

        PictureUpdater.call(user, picture_params, params[:urls])
      end

      def user_response(user, pictures_param_name: :pic)
        {
          id: user.id,
          pictures_param_name => [user.picture&.first_pic, user.picture&.urls&.split(',')].compact.flatten
        }
      end
    end
  end
end
