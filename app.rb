require 'sinatra/base'
require 'aws-sdk-core'
require 'open-uri'
require 'json'
require 'erubi'

class Awsuserjump < Sinatra::Base
  get '/' do
    erb :index
  end

  get '/login' do
    sts = Aws::STS::Client.new(region: 'ap-northeast-1')

    session_name = ENV['RACK_ENV'] == 'production' ? request.env.fetch('HTTP_X_NGX_OMNIAUTH_USER') : 'test'
    resp = sts.assume_role(
      duration_seconds: 3600,
      role_arn: 'arn:aws:iam::550372229658:role/FederatedHSCUser',
      role_session_name: session_name,
    )
    json = {sessionId: resp.credentials.access_key_id, sessionKey: resp.credentials.secret_access_key, sessionToken: resp.credentials.session_token}.to_json
    signin_token = JSON.parse(open("https://signin.aws.amazon.com/federation?Action=getSigninToken&Session=#{URI.encode_www_form_component(json)}", 'r', &:read))

    url = "https://signin.aws.amazon.com/federation?Action=login&Issuer=#{URI.encode_www_form_component("https://awssimple.ioi18.net")}&Destination=#{URI.encode_www_form_component(params[:relay] || 'https://ap-northeast-1.console.aws.amazon.com/console/home?region=ap-northeast-1')}&SigninToken=#{signin_token.fetch("SigninToken")}"
    redirect url
  end
end
