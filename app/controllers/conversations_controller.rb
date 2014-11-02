require 'will_paginate/array' 
class ConversationsController < ApplicationController
  load_and_authorize_resource
  before_filter :authenticate_user!
  before_filter :load_data, only: [:index, :reply, :show, :remove]
  before_filter :mark_post, only: [:show]
  respond_to :html, :js, :xml, :json, :mobile
  layout :page_layout

  def index
    respond_with(@conversations = Conversation.get_specific_conversations(@user, @status).paginate(page: @page, per_page: @per_page))
  end

  def create
    @conversation = Conversation.new params[:conversation]
    respond_with(@conversation) do |format|
      @post = @conversation.posts.build params[:post]
      if @conversation.save
        format.json { render json: {conversation: @conversation} }
      else
        format.json { render json: { errors: @conversation.errors.full_messages }, status: 422 }
      end
    end
  end

  def destroy
    @conversation = Conversation.find params[:id]
    @conversation.destroy  
    respond_with(@conversation)
  end

  def remove 
    @conversation = Conversation.find params[:id]
    if Conversation.remove_conv(@conversation, @user)
      redirect_to conversations_path(status: @status)
    else
      flash[:error] = "Conversation was not removed. Please try again."
      render :nothing => true
    end
  end

  def reply 
    @conversation = Conversation.find(params[:id])
    if @conversation
      respond_with(@conversation) do |format|
        @post = @conversation.posts.build(params[:post])
        if @conversation.save
          @conversation = @conversation.reload
	  load_posts
          format.json { render json: {conversation: @conversation} }
        else
          format.json { render json: { errors: @conversation.errors.full_messages }, status: 422 }
        end
      end
    end
  end

  def show
    @conversation = Conversation.inc_show_list.find(params[:id])
    load_posts
    respond_with(@conversation)
  end

  private

  def page_layout
    mobile_device? && %w(index sent).detect{|x| action_name == x} ? 'form' : 'application'
  end

  def load_data
    @page, @per_page, @status = params[:page] || 1, params[:per_page] || 10, params[:status]
  end

  def load_posts
    @posts, @post = @conversation.posts.active_status(@user), @conversation.posts.build if @conversation
  end

  def mark_post
    @conversation = Conversation.find params[:id]
    @conversation.mark_all_posts(@user) if @conversation
  end
end
