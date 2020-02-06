# frozen_string_literal: true

class Repository < ApplicationRecord
  # It is easier overall to use the GitHub ID for relation management.
  # It allows us to maintain, update or the Repository or PullRequest without
  # the counterpart.
  has_many(:pull_requests,
           primary_key: :github_id,
           foreign_key: :gh_repository_id,
           inverse_of: :repository,
           dependent: :destroy)
  has_many(:open_pull_requests,
           -> { where(state: 'open') },
           class_name: 'PullRequest',
           primary_key: :github_id,
           foreign_key: :gh_repository_id,
           inverse_of: :repository)
  has_one :module

  ##
  #  Checks if the given Repository name is in our application scope (a module)

  def self.notably?(name)
    /^puppet-(?!lint)/.match?(name) && LEGACY_OR_BROKEN_NOBODY_KNOWS.exclude?(name)
  end

  def actions_needed
    @actions_needed ||= begin
                          actions = []
                          data = JSON.parse(RedisClient.client.get('repo_status_data').to_s)
                          data.each do |action, repos|
                            actions << action if repos.include? name
                          end
                          actions
                        rescue JSON::ParserError
                          nil
                        end
  end

  def github_url
    'https://github.com/' + full_name
  end

  ##
  #  Check if the Label exists in the Repository
  #  If we get a 404 create the Label.

  def ensure_label_exists(label)
    Github.client.label(github_id, label.name)
  rescue Octokit::NotFound
    Github.client.add_label(github_id, label.name, label.color)
  end

  ##
  #  Delete the given Label from the Repository
  #
  def ensure_label_missing(label)
    Github.client.delete_label!(github_id, label.name)
  rescue Octokit::NotFound
    true
  end

  ##
  #  Fetch all open and closed PullRequests and sync our database with them
  #
  def update_pull_requests(only_open: false)
    open_pull_requests = Github.client.pull_requests("voxpupuli/#{name}")
    closed_pull_requests = if only_open
                             []
                           else
                             Github.client.pull_requests("voxpupuli/#{name}", state: :closed)
                           end

    (open_pull_requests + closed_pull_requests).each do |gh_pull_request|
      PullRequest.update_with_github(gh_pull_request)
    end

    pull_requests.count
  end

  def update_forge_module
    # we should save the json in Redis and cache it
    content = Github.client.contents("voxpupuli/#{name}", path: 'metadata.json', query: { ref: 'master' })
    metadata = content[:content]
    module_name = JSON.load(Base64.decode64(metadata))['name']
    # somehow save the result from the following lib in the module model
    Forge.module(module_name)
  end
end
