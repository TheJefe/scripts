#!/usr/bin/env ruby

require 'httparty'

GITHUB_TOKEN=ENV['GITHUB_TOKEN']
GITHUB_USERNAME=ENV['GITHUB_USERNAME']
GITHUB_BASE_URL="https://api.github.com"
ORG_NAME="thinkthroughmath"
APP_LIST=["apangea","lesson-player","reporting","live_teaching","ux-pattern"]
QA_LABELS="Needs+QA"
DEV_LABELS="Needs+Code+Review"
ISSUES_ENDPOINT="issues?access_token=#{GITHUB_TOKEN}&sort=updated"

@find_qa_issues = true
@find_dev_issues = false

def get_qa_issues_for(app_name)
  HTTParty.get("#{GITHUB_BASE_URL}/repos/#{ORG_NAME}/#{app_name}/#{ISSUES_ENDPOINT}&labels=#{QA_LABELS}",
      {
      :headers => { 'User-Agent' => GITHUB_USERNAME, 'Content-Type' => 'application/json', 'Accept' => 'application/json'}
      })
end

def get_dev_issues_for(app_name)
  HTTParty.get("#{GITHUB_BASE_URL}/repos/#{ORG_NAME}/#{app_name}/#{ISSUES_ENDPOINT}&labels=#{DEV_LABELS}",
      {
      :headers => { 'User-Agent' => GITHUB_USERNAME, 'Content-Type' => 'application/json', 'Accept' => 'application/json'}
      })
end

def get_all_issues
  all_issues = []
  APP_LIST.each do |app_name|
    issues = []
    issues.concat( get_qa_issues_for(app_name) ) if @find_qa_issues
    issues.concat( get_dev_issues_for(app_name) ) if @find_dev_issues
    all_issues.concat(issues) unless issues.empty?
  end
  all_issues
end

def print(issues)
  issues.each do |issue|
    formatedTime = (Time.parse(issue['updated_at']) + Time.zone_offset('EST')).strftime('%Y-%m-%d %I:%M:%S').to_s
    puts issue['html_url'] + " : " + issue['title'] + " : " + formatedTime
  end
end

# MAIN

unless ARGV[0].nil?
  if ARGV[0].casecmp("dev") == 0
    @find_qa_issues = false
    @find_dev_issues = true
  elsif ARGV[0].casecmp("qa")== 0
    @find_qa_issues = true
    @find_dev_issues = false
  end
end

issues = get_all_issues
print issues
