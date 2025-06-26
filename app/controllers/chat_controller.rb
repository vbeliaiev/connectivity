

class ChatController < ApplicationController
    def new
      @response = nil
    end

    def create
      AiChatService.new.call(params[:message], chat_history: session[:chat_history], current_user:).then do |result|
        if result.success?
          session[:chat_history] = result.value!
        else
          flash[:warn] = result.failure
        end
      end

      render :new
    end
  end
