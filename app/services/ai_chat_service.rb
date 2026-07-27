require 'openai'
require 'dry/monads'

class CreateArticle < OpenAI::BaseModel
  required :title, String, doc: "Short descriptive title of the article"
  required :page, String, doc: "Content of the article"
end

class AiChatService
  include Dry::Monads[:result]

  SYSTEM_ROLE = <<~TEXT
    You are an assistant. Use the CreateArticle function if you need to create an article.

    Always provide a short, descriptive `title` for the article in addition to its `page` content.

    When using the CreateArticle function, if the article includes any formatting (such as bold text, italics, lists, links, or other rich content), format the `page` field using Action Text-compatible HTML (as used by the Trix editor).

    If formatting is needed, wrap the content in a `<div class="trix-content">...</div>` and use standard inline HTML tags for structure:
    - `<strong>` for bold
    - `<em>` for italic
    - `<ul>` / `<ol>` / `<li>` for lists
    - `<a href="...">...</a>` for links

    Do **not** include `<action-text-attachment>` or images unless explicitly instructed.
    Ensure clean and semantically correct HTML inside the wrapper. Use consistent spacing and indentation.
  TEXT

  TEMPERATURE = 0.7
  MAX_CHAT_HISTORY_SIZE = 10

  def initialize
    @client = OpenAI::Client.new(api_key: Rails.application.credentials[:openai_key])
  end

  def call(user_input, chat_history: nil, current_user:)
    chat_history ||= [{ role: "system", content: SYSTEM_ROLE }]
    chat_history << { role: "user", content: user_input }

    ai_response = get_ai_response(chat_history)

    tool_calls = ai_response.choices.first.message.tool_calls

    if tool_calls.present?
      response = tool_calls.first.function.then { |fn| perform_tool_call(fn, current_user:) }
    else
      response = ai_response.choices.first.message.content
    end

    chat_history << { role: "assistant", content: response }
    chat_history.map(&:stringify_keys!)

    truncate_chat_history(chat_history).then { |res| Success(res) }

  rescue StandardError => e
    Failure(e.message)
  end

  private

  attr_reader :client

  def get_ai_response(chat_history)
    client.chat.completions.create(
      model: "gpt-4",
      messages: chat_history,
      tools: [CreateArticle],
      temperature: 0.7
    )
  end

  def perform_tool_call(function, current_user:)
    case function.name
    when 'CreateArticle'
      article_relations = { parent: Node.generic_folder_for(current_user.id),
                         author: current_user,
                         organisation: current_user.current_organisation }
      arguments = JSON.parse(function.arguments).merge(article_relations)

      article = Article.create(arguments)

      "Article with arguments is created. ID: #{article.id}"
    else
      warn_message = 'AiChatService: Undefined tool function has been called'
      Rails.logger.warn(warn_message)

      warn_message
    end
  end

  def truncate_chat_history(messages)
    # +1 is reserved for the initial system role message, so don't count this because it's not displayed for the user.
    return messages if messages.count > MAX_CHAT_HISTORY_SIZE + 1

    [messages.first] + messages.last(MAX_CHAT_HISTORY_SIZE)
  end

end
