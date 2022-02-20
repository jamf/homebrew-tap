require 'json'
require 'formula'
require_relative 'lib/private'

class Hermes < Formula
  release = JSON.parse(File.open(File.expand_path("../../hermes/release.json", __FILE__)).read)

  version release["version"]
  if Hardware::CPU.arm?
    url "https://github.com/jamf/k8s-hermes-cli/releases/download/#{version}/hermes-darwin-arm64.tar.gz", :using => GitHubPrivateRepositoryReleaseDownloadStrategy
    sha256 release["armsha"]
  end
  if Hardware::CPU.intel?
    url "https://github.com/jamf/k8s-hermes-cli/releases/download/#{version}/hermes-darwin-amd64.tar.gz", :using => GitHubPrivateRepositoryReleaseDownloadStrategy
    sha256 release["amdsha"]
  end
  
  desc "Hermes CLI"
  homepage "https://github.com/jamf/k8s-hermes-cli"

  def install
    bin.install "hermes"
  end

  test do
    
  end
end
