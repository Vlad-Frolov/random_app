# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PictureUpdater do
  describe '.call' do
    subject { described_class.call(user, picture_params, urls) }

    let(:first_url) { 'http://example.com/1.jpg' }
    let(:second_url) { 'http://example.com/2.jpg' }
    let(:third_url) { 'http://example.com/3.jpg' }
    let(:picture_params) { { first_pic: 'http://example.com/pic.jpg', urls: "#{first_url},#{second_url}" } }
    let(:urls) { "#{first_url},#{second_url}" }
    let(:user) { User.create }

    before { allow(PictureItemSynchronizer).to receive(:call) }

    context 'when the user has an existing picture' do
      let!(:user_picture) { user.create_picture!(first_pic: 'some_first_pic', urls: 'url_1,url_2') }

      it 'creates the picture and synchronizes picture items' do
        expect { subject }.to change { Picture.count }.by(0).and change { user_picture.first_pic }.to(picture_params[:first_pic])
          .and change { user_picture.urls }.to(urls)

        expect(PictureItemSynchronizer).to have_received(:call).with(user, urls)
      end
    end

    context "when the user doesn't have an existing picture" do
      it 'creates the picture and synchronizes picture items' do
        expect { subject }.to change { Picture.count }.by(1)
        expect(user.picture.first_pic).to eq(picture_params[:first_pic])
        expect(user.picture.urls).to eq(urls)

        expect(PictureItemSynchronizer).to have_received(:call).with(user, urls)
      end
    end
  end
end
