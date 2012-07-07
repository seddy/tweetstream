require 'spec_helper'

describe TweetStream::Client do
  before do
    @stream = stub("EM::Twitter::Client",
      :connect => true,
      :unbind => true,
      :each => true,
      :on_error => true,
      :on_max_reconnects => true,
      :on_reconnect => true,
      :connection_completed => true,
      :on_no_data_received => true,
      :on_unauthorized => true,
      :on_enhance_your_calm => true
    )
    EM.stub!(:run).and_yield
    EM::Twitter::Client.stub!(:connect).and_return(@stream)
  end

  describe "basic auth" do
    before do
      TweetStream.configure do |config|
        config.username = 'tweetstream'
        config.password = 'rubygem'
        config.auth_method = :basic
      end

      @client = TweetStream::Client.new
    end

    it 'should try to connect via a JSON stream with basic auth' do
      EM::Twitter::Client.should_receive(:connect).with(
        :path => URI.parse('/1/statuses/filter.json'),
        :method => 'POST',
        :user_agent => TweetStream::Configuration::DEFAULT_USER_AGENT,
        :on_inited => nil,
        :params => {:track => 'monday'},
        :basic => {
          :username => 'tweetstream',
          :password => 'rubygem'
        }
      ).and_return(@stream)

      @client.track('monday')
    end
  end

  describe "oauth" do
    before do
      TweetStream.configure do |config|
        config.consumer_key = '123456789'
        config.consumer_secret = 'abcdefghijklmnopqrstuvwxyz'
        config.oauth_token = '123456789'
        config.oauth_token_secret = 'abcdefghijklmnopqrstuvwxyz'
        config.auth_method = :oauth
      end

      @client = TweetStream::Client.new
    end

    it 'should try to connect via a JSON stream with oauth' do
      EM::Twitter::Client.should_receive(:connect).with(
        :path => URI.parse('/1/statuses/filter.json'),
        :method => 'POST',
        :user_agent => TweetStream::Configuration::DEFAULT_USER_AGENT,
        :on_inited => nil,
        :params => {:track => 'monday'},
        :oauth => {
          :consumer_key => '123456789',
          :consumer_secret => 'abcdefghijklmnopqrstuvwxyz',
          :token => '123456789',
          :token_secret => 'abcdefghijklmnopqrstuvwxyz'
        }
      ).and_return(@stream)

      @client.track('monday')
    end
  end

end
