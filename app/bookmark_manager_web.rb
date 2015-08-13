require 'sinatra/base'
require 'sinatra/session'
require_relative "../data_mapper_setup"
require_relative "./models/link"
require_relative "./models/tag"
require_relative "./models/user"

class BookmarkManager < Sinatra::Base

  enable :sessions
  set :session_secret, "super secret"

  get '/' do
    erb :home
  end

  get "/links" do
    @links = Link.all
    erb :index
  end

  get '/links/new' do
    erb :link
  end

  post '/links' do
    link = Link.new(url: params[:url], title: params[:title])
    (params[:tags].split).each do |tag|
      tag = Tag.first_or_create(name: tag)
      link.tags << tag  
    end
    link.save
    redirect to('/links')
  end

  get "/tags" do
    redirect to("/tags/#{params[:name]}")
  end

  get '/tags/:name' do
    tag = Tag.first(name: params[:name])
    @links = tag ? tag.links : []
    erb :index
  end

  get "/users/new" do
    erb :'users/new'
  end

  post "/users" do
    user = User.create(email: params[:email], password: params[:password])
    session[:user_id] = user.id
    redirect to("/")
  end

  helpers do
    def current_user
      User.get(session[:user_id])
    end
  end

  # start the server if ruby file executed directly
  run! if app_file == $0
end
