#coding: utf-8
require 'bundler'
Bundler.require
require 'pp'
require 'csv'

require './myid'
require './twitterApi'

def main()	
	baseUrl='https://site2.sbisec.co.jp'
	agent=Mechanize.new
	savePath="data/"
	#twitterApi=TwitterApi.new($consumer_key,$consumer_secret,$access_token,$access_token_secret)
	
	begin
		FileUtils.mkdir_p(savePath) unless FileTest.exist?(savePath)
		sbiLogin(baseUrl,agent)
		getStockNews(agent,baseUrl,3528)
	end
end

def sbiLogin(baseUrl,agent)
	loginUrl=baseUrl+'/ETGate/'
	# ログイン処理
	agent.get(loginUrl) do |page|
		page.form_with(:name=> 'form_login') do |form|
			form.field_with(:name => 'user_id').value =$login_id
			form.field_with(:name => 'user_password').value = $login_password
		end.submit
	end
end

def csvSave(body,savePath)
	#現在時刻を取得
	date=Time.now.strftime("%Y%m%d")
	first=0
	csvSavePath=savePath+date+".csv"
	CSV.open(csvSavePath,"w") do end
	body.xpath('//tr[@align="center"]').each_with_index do |node1,i|
		list=Array.new
		node1.xpath('./td').each_with_index do |node2,j|
			if node2.text=='取引' and first==0
				first=1
			elsif first==0
				next
			elsif node2.text=='株式(現物/NISA預り)合計'
				break
			end
			list[j]=node2.text
		end
		list.delete_at(0)
		list.delete_at(-1)
		CSV.open(csvSavePath,"a") do |csv|
			csv<<list
		end
	end
end

def getStockNews(agent,baseUrl,code)
	code=code.to_s
	url=baseUrl+'/ETGate/?_ControlID=WPLETsiR001Control&_PageID=WPLETsiR001Idtl20&_DataStoreID=DSWPLETsiR001Control&_ActionID=DefaultAID&s_rkbn=&s_btype=&i_stock_sec='+code+'&i_dom_flg=1&i_exchange_code=TKY&i_output_type=1&exchange_code=TKY&stock_sec_code_mul='+code+'&ref_from=1&ref_to=20&wstm4130_sort_id=&wstm4130_sort_kbn=&qr_keyword=&qr_suggest=&qr_sort='
	page=agent.get(url)
	body=Nokogiri::HTML(page.body)
	news=Array.new
	body.xpath('//td[@class="sbody"]').each_with_index do |node,i|
		news[i]=Hash.new
		text=removeToken(node.text)
		#?を削除
		newText=text[1,5]+' '+text[8,5]	
		news[i]['date']=newText
		node.xpath('./..//a').each do |node1|
			news[i]['title']=removeToken(node1.text)
		end
	end

	pp news
end

def removeToken(text)
	while(text.index("\r")!=nil)do text.slice!("\r") end
	while(text.index("\n")!=nil)do text.slice!("\n") end
	while(text.index("\t")!=nil)do text.slice!("\t") end

	return text
end

main()
