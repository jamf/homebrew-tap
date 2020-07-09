class Rendr < Formula
  desc "A rapid application development toolset"
  homepage "https://github.com/jamf/rendr"

  release_metadata = YAML.load(File.open(File.expand_path("../../metadata/rendr.yaml", __FILE__)).read)

  url release_metadata["url"]
  version release_metadata["version"]
  sha256 release_metadata["sha256"]

  def install
    bin.install "rendr-darwin"
    mv bin/"rendr-darwin", bin/"rendr"
  end

  test do
    system "#{bin}/rendr", "--help"
  end
end
