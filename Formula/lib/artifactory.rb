require 'uri'
require 'net/http'

class AccessDeniedError < StandardError

end

class ArtifactoryDownloadStrategy < CurlDownloadStrategy
    require "utils/formatter"
  
    def initialize(url, name, version, **meta)
      super
      ohai "initializing artifactory downloader"
      parse_url_pattern
      test_connection
    end

    def test_connection
      begin
        ohai "testing connection to artifactory"
        url = URI.parse("https://artifactory.jamf.build/artifactory/api/system/ping")
        req = Net::HTTP::Get.new(url.to_s)

        # setting both OpenTimeout and ReadTimeout
        res = Net::HTTP.start(url.host, url.port, :open_timeout => 3, :read_timeout => 3) {|http|
          http.request(req)
        }
      rescue Net::OpenTimeout, Net::ReadTimeout => e
        odie "Artifactory is NOT reachable"
      end
    end

    def parse_url_pattern
        unless match = url.match(%r{https://github.com/([^/]+)/([^/]+)/([^/]+)/([^/]+)/([^/]+)/([^/]+)})
          raise CurlDownloadStrategyError, "Invalid url pattern for GitHub Repository."
        end
    
        _, @owner, @repo, @releases, @download, @version, @filename = *match
        @url = "https://artifactory.jamf.build/artifactory/binaries/#{@repo}/#{version}/#{@filename}"
    end
    
    def download_url
        @url
    end
  
    private
  
    def _fetch(url:, resolved_url:, timeout:)
      curl_download download_url, to: temporary_path
    end
  
  end


## Download factory tests Github first and if not accessible attempts to use Artifactory
class DownloadFactory < CurlDownloadStrategy
  def self.new(url, name, version, **meta)
    begin
      github = GitHubPrivateRepositoryReleaseDownloadStrategy.new(url, name, version, **meta)
    rescue AccessDeniedError, EnvironmentMissingError => e
      opoo e.message
      artifactory = ArtifactoryDownloadStrategy.new(url, name, version, **meta)
    end
  end
end
  