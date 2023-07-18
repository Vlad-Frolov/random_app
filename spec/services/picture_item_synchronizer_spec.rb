# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PictureItemSynchronizer do
  describe '.call' do
    subject { described_class.call(user, urls) }

    let(:first_url) { 'http://example.com/1.jpg' }
    let(:second_url) { 'http://example.com/2.jpg' }
    let(:third_url) { 'http://example.com/3.jpg' }
    let(:urls) { [first_url, second_url] }
    let(:user) { User.create }

    context 'when picture items already exist for the user' do
      let!(:existing_item1) { PictureItem.create(user: user, url: first_url) }
      let!(:existing_item2) { PictureItem.create(user: user, url: third_url) }

      it 'synchronizes the picture items' do
        expect { subject }.to change { user.picture_items.pluck(:url) }.to(urls)
      end

      it 'removes the picture item with the third url but adds a picture item with the first url' do
        expect { subject }.not_to change { user.picture_items.count }

        expect(user.picture_items.pluck(:url)).not_to include(third_url)
      end
    end

    context 'when no picture items exist for the user' do
      it 'creates the picture items' do
        expect { subject }.to change { user.picture_items.count }.from(0).to(2)

        expect(user.picture_items.pluck(:url)).to match_array(urls)
      end
    end
  end
end
