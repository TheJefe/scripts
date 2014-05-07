#!/usr/bin/env ruby

require 'httparty'

GITHUB_TOKEN=ENV['GITHUB_TOKEN']
GITHUB_USERNAME=ENV['GITHUB_USERNAME']
GITHUB_BASE_URL="https://api.github.com"
ORG_NAME="thinkthroughmath"
APP_LIST=["apangea","lesson-player","reporting","live_teaching"]
LABELS="Needs+QA" #comma delimited list
ISSUES_ENDPOINT="issues?access_token=#{GITHUB_TOKEN}&labels=#{LABELS}"


def get_issues_for(app_name)
  HTTParty.get("#{GITHUB_BASE_URL}/repos/#{ORG_NAME}/#{app_name}/#{ISSUES_ENDPOINT}",
      {
      :headers => { 'User-Agent' => GITHUB_USERNAME, 'Content-Type' => 'application/json', 'Accept' => 'application/json'}
      })
end

def get_all_issues
  all_issues = []
  APP_LIST.each do |app_name|
    issues = get_issues_for(app_name)
    all_issues.concat(issues)unless issues.empty?
  end
  all_issues
end

def print(issues)
  issues.each do |issue|
    puts issue['html_url'] + " : " + issue['title']
  end
end

# MAIN
issues = get_all_issues
print issues
