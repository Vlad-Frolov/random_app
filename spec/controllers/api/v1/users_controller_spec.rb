# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :controller do
  let(:first_picture) { 'http://foo.io/1.jpg' }
  let(:second_picture) { 'http://foo.io/2' }
  let(:third_picture) { 'http://foo.io/3' }

  describe 'GET #index' do
    before do
      3.times.each do
        user = User.create!
        user.create_picture!(first_pic: first_picture, urls: "#{second_picture},#{third_picture}")
      end
    end

    it 'returns the list of users with pictures' do
      get :index

      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body).count).to eq(3)
      expect(JSON.parse(response.body)[0]).to eq({
        'id' => 1,
        'pic' => [first_picture, second_picture, third_picture]
      })
    end
  end

  describe 'PATCH #update' do
    subject { patch :update, id: user.id, **picture_update_params }

    let(:expected_response_body_json) { { 'id' => user.id, 'pictures' => [first_picture, third_picture] } }
    let(:user) { User.create }

    let(:picture_update_params) do
      {
        first_pic: first_picture,
        urls: [third_picture]
      }
    end

    shared_examples 'returns the expected response body json' do
      it do
        subject

        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)).to eq(expected_response_body_json)
      end
    end

    context "when the picture doesn't exist" do
      it_behaves_like 'returns the expected response body json'

      it 'creates a new picture' do
        expect { subject }.to change { Picture.count }.by(1)
      end
    end

    context 'when the picture exists' do
      before do
        user.create_picture!(
          first_pic: first_picture,
          urls: "#{second_picture},#{third_picture}"
        )
      end

      it "doesn't create a new picture" do
        expect { subject }.not_to change { Picture.count }
      end

      context 'when picture update params are not passed' do
        let(:expected_response_body_json) { { 'id' => user.id, 'pictures' => [] } }
        let(:picture_update_params) { {} }

        it 'returns the expected bad request response' do
          subject

          expect(response).to have_http_status(400)
          expect(JSON.parse(response.body)).to eq('error' => "Validation failed: Urls can't be blank")
        end
      end

      context 'when picture update params are passed' do
        it_behaves_like 'returns the expected response body json'

        context 'when changing the order of picture urls' do
          let(:expected_response_body_json) { { 'id' => user.id, 'pictures' => [third_picture, second_picture, first_picture] } }

          let(:picture_update_params) do
            {
              first_pic: third_picture,
              urls: [second_picture, first_picture]
            }
          end

          it_behaves_like 'returns the expected response body json'
        end
      end
    end
  end
end
