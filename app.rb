# app.rb
require 'sinatra'
require 'httparty'
require 'json'
require 'dotenv/load'
set :bind, '0.0.0.0'
set :port, 3000
disable :protection 

get '/' do
  "I'm alive! This is LINE x ChatGPT bot."
end
post '/webhook' do
  request_body = request.body.read
  body = JSON.parse(request_body)

  body['events'].each do |event|
    if event['type'] == 'message' && event['message']['type'] == 'text'
      user_message = event['message']['text']
      reply_token = event['replyToken']

      # ChatGPTへの問い合わせ
      ai_reply = ask_chatgpt(user_message)

      # LINEへ返信
      reply_to_line(reply_token, ai_reply)
    end
  end

  status 200
end

def ask_chatgpt(message)
  response = HTTParty.post(
    'https://api.openai.com/v1/chat/completions',
    headers: {
      'Content-Type' => 'application/json',
      'Authorization' => "Bearer #{ENV['OPENAI_API_KEY']}"
    },
    body: {
      model: 'gpt-4',
      messages: [
        { role: 'user', content: message }
      ]
    }.to_json
  )

  response.parsed_response.dig('choices', 0, 'message', 'content') || 'うまく返答できませんでした。'
end

def reply_to_line(reply_token, message)
  HTTParty.post(
    'https://api.line.me/v2/bot/message/reply',
    headers: {
      'Content-Type' => 'application/json',
      'Authorization' => "Bearer #{ENV['LINE_CHANNEL_ACCESS_TOKEN']}"
    },
    body: {
      replyToken: reply_token,
      messages: [{ type: 'text', text: message }]
    }.to_json
  )
end
