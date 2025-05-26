require 'openai'

class CreateNote < OpenAI::BaseModel
  required :content, String, doc: "Content of the note"
end


class ChatController < ApplicationController
    def new
      @response = nil
    end
  
    def create
      user_input = params[:message]
  
      client = OpenAI::Client.new(api_key: Rails.application.credentials[:openai_key])

      response = client.chat.completions.create(
        model: "gpt-4",
        messages: [
        { role: "system", content: "You are an assistant. Use the CreateNote function if you need to create a note." },
        { role: "user", content: user_input }
        ],
        tools: [CreateNote],
        temperature: 0.7
      )

      tool_calls = response.choices.first.message.tool_calls

      if tool_calls.present?
        function = tool_calls.first.function
        case function.name
        when 'CreateNote'
          arguments = JSON.parse(function.arguments)
          note = Note.create(arguments)
          @response = "Note with arguments: #{arguments} is created. ID: #{note.id}"
        else
          puts 'undefined'
        end
      else
        @response = response.choices.first.message.content
      end

      @user_input = user_input
  
      render :new
    end    
  end
  