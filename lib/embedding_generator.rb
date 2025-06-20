class EmbeddingGenerator
  def self.generate(text)
    return '' if Rails.env.test?
    client = OpenAI::Client.new(api_key: Rails.application.credentials[:openai_key])

    response = client.embeddings.create(
      model: "text-embedding-3-small",
      input: text
    )

    response.data.first.embedding
  end
end
