require 'spec_helper'

describe Topping::Configurable do
  let(:root) { MockApplication::Application }
  let(:net) { MockApplication::Features::Net }
  let(:user) { MockApplication::Features::User }
  describe 'Root config' do
    before do
      root.build
      root.configure do |c|
        c.store = :redis
        c.name = 'bot_app'
      end
    end
    it 'can get the value set for the root class' do
      expect(root.config.dir).to eq 'work'
      expect(root.config.store).to eq :redis
      expect(root.config.name).to eq 'bot_app'
    end
  end
  describe 'HQ -> leaf' do
    before do
      root.build
      net.configure do |c|
        c.host = 'rike422.com'
        c.port = 80
      end
      user.configure do |c|
        c.username = 'akira takahashi'
        c.password = 'password'
      end
    end
    it 'can get the value set for the child class' do
      expect(root.config.features.net.host).to eq 'rike422.com'
      expect(root.config.features.net.port).to eq 80
      expect(root.config.features.user.username).to eq 'akira takahashi'
      expect(root.config.features.user.password).to eq 'password'
    end

    context 'leaf -> HQ' do
      let(:net_i) { net.new }
      let(:user_i) { user.new }
      before do
        root.configure do |c|
          c.features.net.host = 'other.com'
          c.features.net.port = 443
          c.features.user.username = 'takahashi_akira'
          c.features.user.password = 'wordpass'
        end
      end
      it 'Can get the value set for the HQ class' do
        expect(net_i.config.host).to eq 'other.com'
        expect(net_i.config.port).to eq 443
        expect(user_i.config.username).to eq 'takahashi_akira'
        expect(user_i.config.password).to eq 'wordpass'
      end
    end

    describe 'a validate!d attribute' do
      it 'raises if the validator raises due to an invalid value' do
        expect { root.config.features.net.protocol = :ftp }.to raise_error(Topping::ValidationError)
      end
    end
  end
end
