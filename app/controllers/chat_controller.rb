

class ChatController < ApplicationController
    def new
      @response = nil
    end

    def create
      AiChatService.new.call(params[:message], session[:chat_history]).then do |result|
        if result.success?
          session[:chat_history] = result.value!
        else
          flash[:warn] = result.failure
        end
      end

      render :new
    end
  end
