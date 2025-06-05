require 'openai'

class CreateNote < OpenAI::BaseModel
  required :page, String, doc: "Content of the note"
end


class ChatController < ApplicationController
    def new
      @response = nil
    end

  
    def create
      user_input = params[:message]
  
      client = OpenAI::Client.new(api_key: Rails.application.credentials[:openai_key])
      system_role = <<~TEXT
        You are an assistant. Use the CreateNote function if you need to create a note.

        When using the CreateNote function, if the note includes any formatting (such as bold text, italics, lists, links, or other rich content), format the `page` field using Action Text-compatible HTML (as used by the Trix editor).

        If formatting is needed, wrap the content in a `<div class="trix-content">...</div>` and use standard inline HTML tags for structure:
        - `<strong>` for bold
        - `<em>` for italic
        - `<ul>` / `<ol>` / `<li>` for lists
        - `<a href="...">...</a>` for links

        Do **not** include `<action-text-attachment>` or images unless explicitly instructed.  
        Ensure clean and semantically correct HTML inside the wrapper. Use consistent spacing and indentation.
      TEXT

      session[:chat_history] ||= [{ role: "system", content: system_role }]
      session[:chat_history] << { role: "user", content: user_input }


      response = client.chat.completions.create(
        model: "gpt-4",
        messages: session[:chat_history],
        tools: [CreateNote],
        temperature: 0.7
      )

      tool_calls = response.choices.first.message.tool_calls

      if tool_calls.present?
        function = tool_calls.first.function
        case function.name
        when 'CreateNote'
          arguments = JSON.parse(function.arguments).merge(parent: Node.generic_folder)
          note = Note.create(arguments)
          @response = "Note with arguments is created. ID: #{note.id}"
        else
          puts 'undefined'
        end
      else
        @response = response.choices.first.message.content
      end

      session[:chat_history] << { role: "assistant", content: @response }

      @user_input = user_input
  
      session[:chat_history].map(&:stringify_keys!)
      session[:chat_history] = session[:chat_history].last(10) if session[:chat_history].size > 10

      render :new
    end    
  end
  