require 'sinatra/base'
require 'erb'
require File.expand_path('../',  __FILE__) + '/web_results'
require File.expand_path('../',  __FILE__) + '/web_helpers'

module StatusPage
  class Web < Sinatra::Base

    set :root, File.expand_path(File.dirname(__FILE__) + "/web")
    set :public_folder, Proc.new { "#{root}/assets" }
    set :views, Proc.new { "#{root}/views" }

    helpers WebHelpers

    get '/' do
      erb :index, locals: { result: WebResults.new }
    end

    get '/history/*' do
      key = params['splat'].first
      records = WebResults.new.history(key)
      erb :history, locals: { records: records, key: key }
    end
  end
end