# frozen_string_literal: true

require 'date'
require "httparty"
require "json"
require 'time'

class JiraEndpoint
  include HTTParty
  base_uri ENV.fetch("JIRA_API_URL", "https://jira.atlassian.com/rest/api/2")

  def initialize(user, token)
    raise ArgumentError, "Missing token" if token.nil? || token.strip.empty?
    raise ArgumentError, "Missing user" if user.nil? || user.strip.empty?

    @user  = user
    @token = token
  end

  def default_opts
    {
      basic_auth: { username: @user, password: @token },
      headers: { 'Content-Type' => 'application/json' },
    }
  end
end
