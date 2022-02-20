# Save this file as `lib/private_strategy.rb`
# Add `require_relative "lib/private_strategy"` to your formula.
# 
# This is based on the following, with minor fixes.
# https://github.com/Homebrew/brew/blob/193af1442f6b9a19fa71325160d0ee2889a1b6c9/Library/Homebrew/compat/download_strategy.rb#L48-L157

# BSD 2-Clause License
#
# Copyright (c) 2009-present, Homebrew contributors
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
#
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# GitHubPrivateRepositoryDownloadStrategy downloads contents from GitHub
# Private Repository. To use it, add
# `:using => GitHubPrivateRepositoryDownloadStrategy` to the URL section of
# your formula. This download strategy uses GitHub access tokens (in the
# environment variables `HOMEBREW_GITHUB_API_TOKEN`) to sign the request.  This
# strategy is suitable for corporate use just like S3DownloadStrategy, because
# it lets you use a private GitHub repository for internal distribution.  It
# works with public one, but in that case simply use CurlDownloadStrategy.
class GitHubPrivateRepositoryDownloadStrategy < CurlDownloadStrategy
    require "utils/formatter"
    require "utils/github"
  
    def initialize(url, name, version, **meta)
      super
      parse_url_pattern
      set_github_token
    end
  
    def parse_url_pattern
      unless match = url.match(%r{https://github.com/([^/]+)/([^/]+)/(\S+)})
        raise CurlDownloadStrategyError, "Invalid url pattern for GitHub Repository."
      end
  
      _, @owner, @repo, @filepath = *match
    end
  
    def download_url
      "https://#{@github_token}@github.com/#{@owner}/#{@repo}/#{@filepath}"
    end
  
    private
  
    def _fetch(url:, resolved_url:, timeout:)
      curl_download download_url, to: temporary_path
    end
  
    def set_github_token
      @github_token = ENV["HOMEBREW_GITHUB_API_TOKEN"]
      unless @github_token
        raise CurlDownloadStrategyError, "Environmental variable HOMEBREW_GITHUB_API_TOKEN is required."
      end
  
      validate_github_repository_access!
    end
  
    def validate_github_repository_access!
      # Test access to the repository
      GitHub.repository(@owner, @repo)
    rescue GitHub::API::HTTPNotFoundError
      # We switched to GitHub::API::HTTPNotFoundError, 
      # because we can now handle bad credentials messages
      message = <<~EOS
        HOMEBREW_GITHUB_API_TOKEN can not access the repository: #{@owner}/#{@repo}
        This token may not have permission to access the repository or the url of formula may be incorrect.
      EOS
      raise CurlDownloadStrategyError, message
    end
  end
  
  # GitHubPrivateRepositoryReleaseDownloadStrategy downloads tarballs from GitHub
  # Release assets. To use it, add
  # `:using => GitHubPrivateRepositoryReleaseDownloadStrategy` to the URL section of
  # your formula. This download strategy uses GitHub access tokens (in the
  # environment variables HOMEBREW_GITHUB_API_TOKEN) to sign the request.
  class GitHubPrivateRepositoryReleaseDownloadStrategy < GitHubPrivateRepositoryDownloadStrategy
    def initialize(url, name, version, **meta)
      super
    end
  
    def parse_url_pattern
      url_pattern = %r{https://github.com/([^/]+)/([^/]+)/releases/download/([^/]+)/(\S+)}
      unless @url =~ url_pattern
        raise CurlDownloadStrategyError, "Invalid url pattern for GitHub Release."
      end
  
      _, @owner, @repo, @tag, @filename = *@url.match(url_pattern)
    end
  
    def download_url
      "https://#{@github_token}@api.github.com/repos/#{@owner}/#{@repo}/releases/assets/#{asset_id}"
    end
  
    private
  
    def _fetch(url:, resolved_url:, timeout:)
      # HTTP request header `Accept: application/octet-stream` is required.
      # Without this, the GitHub API will respond with metadata, not binary.
      curl_download download_url, "--header", "Accept: application/octet-stream", to: temporary_path
    end
  
    def asset_id
      @asset_id ||= resolve_asset_id
    end
  
    def resolve_asset_id
      release_metadata = fetch_release_metadata
      assets = release_metadata["assets"].select { |a| a["name"] == @filename }
      raise CurlDownloadStrategyError, "Asset file not found." if assets.empty?
  
      assets.first["id"]
    end
  
    def fetch_release_metadata
      release_url = "https://api.github.com/repos/#{@owner}/#{@repo}/releases/tags/#{@tag}"
      GitHub::API.open_rest(release_url)
    end
  end
