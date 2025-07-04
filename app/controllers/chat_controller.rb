class ChatController < ApplicationController
  after_action :verify_pundit_authorization

  def new
    authorize(nil, policy_class: ChatPolicy)

    @response = nil
  end

  def create
    authorize(nil, policy_class: ChatPolicy)

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
