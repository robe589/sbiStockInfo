#coding: utf-8
require 'bundler'
Bundler.require

class TwitterApi
	def initialize(consumer_key,consumer_secret,access_token,access_token_secret)
		#ツイッターログイン処理
		@client = Twitter::REST::Client.new do |config|
			config.consumer_key=consumer_key#API Key
			config.consumer_secret=consumer_secret#API secret
			config.access_token=access_token #Access token
			config.access_token_secret=access_token_secret #Access token secret
		end
	end

	#ツイッターに投稿
	def write(str)
		@client.update(str)
	end
end
