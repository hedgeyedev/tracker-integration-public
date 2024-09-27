# frozen_string_literal: true

class Category < JiraEndpoint
  def create(description)
    self.class.post(
      '/projectCategory',
      { body: { name: description.gsub(' ', '-'), description: description }.to_json }.merge(default_opts),
    )
  end
end
