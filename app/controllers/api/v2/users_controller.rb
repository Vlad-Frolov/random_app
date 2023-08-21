# frozen_string_literal: true

module Api
  module V2
    class UsersController <  ::Api::UsersController
      private

      def picture_entity_key
        :picture_items
      end

      def update_picture(user)
        picture_item = user.picture_items.find { |item| item.url == params[:url] }

        return picture_item if picture_item

        user.picture_items.create!(url: params[:url])
      end

      def user_response(user, pictures_param_name: :pic)
        {
          id: user.id,
          pictures_param_name => user.picture_items.map(&:url).compact
        }
      end
    end
  end
end
