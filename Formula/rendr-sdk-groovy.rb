class RendrSdkGroovy < Formula
  desc "A rapid application development toolset - Groovy SDK"
  homepage "https://github.com/jamf/rendr-sdk-groovy"

  release_metadata = YAML.load(File.open(File.expand_path("../../metadata/rendr-sdk-groovy.yaml", __FILE__)).read)

  url release_metadata["url"]
  version release_metadata["version"]
  sha256 release_metadata["sha256"]

  def install
    bin.install "bin/rendr-sdk-groovy"
    prefix.install "lib"
  end

  test do
    system "#{bin}/rendr-sdk-groovy", "--help"
  end
end
