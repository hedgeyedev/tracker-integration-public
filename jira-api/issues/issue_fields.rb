# frozen_string_literal: true

class IssueFields < JiraEndpoint
  def self.load_fields(user, token, issue_type_id, project_id: "10000")
    response = get(
      "/issue/createmeta/#{project_id}/issuetypes/#{issue_type_id}",
      self.new(user, token).default_opts,
    )

    raise "Failed to load fields: #{response.code}" unless response.success?
    response.parsed_response["fields"].map.with_object({}) do |field, hash|
      hash[field["name"]] = field
    end
  end
end
