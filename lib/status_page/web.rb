require 'sinatra/base'
require 'erb'
require File.expand_path('../client',  __FILE__)
require File.expand_path('../web_results',  __FILE__)
require File.expand_path('../web_helpers',  __FILE__)

module StatusPage
  class Web < Sinatra::Base

    set :root, File.expand_path(File.dirname(__FILE__) + "/web")
    set :public_folder, Proc.new { "#{root}/assets" }
    set :views, Proc.new { "#{root}/views" }

    helpers WebHelpers

    get '/' do
      erb :index, locals: { result: WebResults.new }
    end

    get '/collect_metrics' do
      Client.new.collect
      redirect back
    end

    get '/history/*' do
      key = params['splat'].first
      records = WebResults.new.history(key)
      erb :history, locals: { records: records, key: key }
    end
  end
end