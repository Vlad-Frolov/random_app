# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V2::UsersController, type: :controller do
  let(:first_picture_item) { 'http://foo.io/1.jpg' }
  let(:second_picture_item) { 'http://foo.io/2' }
  let(:third_picture_item) { 'http://foo.io/3' }

  describe 'GET #index' do
    before do
      3.times.each do
        user = User.create!
        user.picture_items.create!(url: first_picture_item)
        user.picture_items.create!(url: second_picture_item)
        user.picture_items.create!(url: third_picture_item)
      end
    end

    it 'returns the list of users with picture items' do
      get :index

      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body).count).to eq(3)
      expect(JSON.parse(response.body)[0]).to eq({
        'id' => 1,
        'pic' => [first_picture_item, second_picture_item, third_picture_item]
      })
    end
  end

  describe 'PATCH #update' do
    subject { patch :update, id: user.id, **picture_item_update_params }

    let(:expected_response_body_json) { { 'id' => user.id, 'pictures' => [second_picture_item] } }
    let(:picture_item_update_params) { { url: second_picture_item } }
    let(:user) { User.create }

    shared_examples 'returns the expected response body json' do
      it do
        subject

        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)).to eq(expected_response_body_json)
      end
    end

    context "when the picture item doesn't exist" do
      it_behaves_like 'returns the expected response body json'

      it 'creates a new picture item' do
        expect { subject }.to change { PictureItem.count }.by(1)
      end
    end

    context 'when the picture item exists' do
      before { user.picture_items.create!(url: second_picture_item)}

      it "doesn't create a new picture item" do
        expect { subject }.not_to change { PictureItem.count }
      end

      context 'when picture item update params are not passed' do
        let(:expected_response_body_json) { { 'id' => user.id, 'pictures' => [] } }
        let(:picture_item_update_params) { {} }

        it 'returns the expected bad request response' do
          subject

          expect(response).to have_http_status(400)
          expect(JSON.parse(response.body)).to eq('error' => "Validation failed: Url can't be blank")
        end
      end

      context 'when picture item update params are passed' do
        it_behaves_like 'returns the expected response body json'
      end
    end
  end
end
