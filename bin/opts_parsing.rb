# frozen_string_literal: true

require 'optparse'
require 'dotenv/load'

[".env.local", ".env"].each do |name|
  Dotenv.load File.expand_path("../#{name}", __dir__)
end

class OptsParsing
  attr_accessor :exit_code
  attr_reader :options

  def initialize(banner: "Usage: #{$PROGRAM_NAME} [options]")
    @exit_code  = 0
    @options    = {
      project_id: ENV["JIRA_DEFAULT_PROJECT_ID"],
      token: ENV["JIRA_API_TOKEN"],
      user: "#{ENV["JIRA_API_USER"]}",
    }

    @opts_parser = OptionParser.new do |opts|
      opts.banner = banner
      opts.on("-p", "--project-id PROJECT_ID", "Project ID (default read from JIRA_DEFAULT_PROJECT_ID)") do |v|
        @options[:project_id] = v
      end
      opts.on("-u", "--user USER", "JIRA API user (default read from JIRA_API_USER)") do |v|
        @options[:user] = v
      end
      opts.on("-t", "--token TOKEN", "JIRA API token (default read from JIRA_API_TOKEN)") do |v|
        @options[:token] = v
      end

      yield opts, @options

      opts.on("-h", "--help", "Prints this help") do
        puts opts
        exit exit_code
      end
    end
  end

  def option?(key)
    options[key].nil? || options[key].strip.empty?
  end

  def parse(args:)
    @opts_parser.parse! args
    self
  end
end
