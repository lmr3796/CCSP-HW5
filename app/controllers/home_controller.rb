require 'json'
class HomeController < ApplicationController
  include RestGraph::RailsUtil
  before_filter :login_facebook, :only => [:login]
  before_filter :load_facebook,  :except => [:login]

  def index
    if rest_graph.access_token
      raw_wall = rest_graph.get('/me/home')["data"]
      post_type=["status", "photo", "link", "checkin", "video", "swf"]
      @wall = Hash[post_type.map{|t| [t,[]]}]
      raw_wall.each{|post|
        @wall[post["type"]] << #post
        { :from => post["from"]. update({"picture" =>("http://graph.facebook.com/"+post["from"]["id"]+"/picture")}), 
          :content => unless post["message"].blank?
                        post["message"] 
                      else 
                        post["story"]
                      end,
          :link    => post["link"]
        }
      }
      #render :json => raw_wall
      #render :json => @wall
    else
      redirect_to :login
    end
  end

  def login
    redirect_to home_path
  end

  def logout
    reset_session
    redirect_to home_path
  end

private
  def load_facebook
    rest_graph_setup(:write_session => true)
  end

  def login_facebook
    rest_graph_setup(:auto_authorize        => true,
                     :auto_authorize_scope  => 'read_stream',
                     #:auto_authorize_scope   => 'publish_checkins',
                     :ensure_authorized     => true,
                     :write_session         => true)
  end
end
