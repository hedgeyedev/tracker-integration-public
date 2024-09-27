# frozen_string_literal: true

require_relative 'jira_endpoint'
require_relative 'issues/issue_fields'

class Issue < JiraEndpoint
  attr_reader :issue_type_id

  def initialize(
    project_id: ENV.fetch("JIRA_DEFAULT_PROJECT_ID", "10000"),
    token: ENV.fetch("JIRA_API_TOKEN", nil),
    user: ENV.fetch("JIRA_API_USER", nil)
  )
    super(user, token)

    @project_id    = project_id
    @issue_type_id = self.class.const_get(:ID) rescue nil
    @fields        = if @issue_type_id
                       IssueFields.load_fields(user, token, @issue_type_id, project_id: @project_id)
                     else
                       {}
                     end
  end

  def create(row, headers)
    self.class.post(
      '/issue',
      {
        body: {
          fields: {
            project: { id: @project_id },
            issuetype: { id: @issue_type_id },
            labels: row[headers.index('Labels') ].split(',').map do |l|
              l.strip.gsub('&', ' and ').gsub(/\W/, '-').gsub(/-+/, '-')
            end,
            description: row[headers.index('Description') ],
            summary: row[headers.index('Title') ],
            field_key("Story point estimate") => row[headers.index('Estimate')].to_i,
          },
        }.to_json,
      }.merge(default_opts),
    )
  end

  def field(name)
    @fields[name]
  end

  def field_key(name)
    field(name)["key"]
  end

  def git_branch_for(issue_key)
    response = issue_details(issue_key)
    summary  = response.dig("fields", "summary")&.gsub(/\W/, '-')&.gsub(/-+/, '-')&.downcase
    "#{issue_key}-#{summary || "no-summary"}"
  end

  def issue_details(issue_key)
    self.class.get("/issue/#{issue_key}", default_opts).parsed_response rescue {}
  end
end

require_relative 'issues/bug'
require_relative 'issues/byline_request'
require_relative 'issues/epic'
require_relative 'issues/spike'
require_relative 'issues/story'
require_relative 'issues/subtask'
require_relative 'issues/task'
