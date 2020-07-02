class Express < Formula
  desc "A rapid application development toolset"
  homepage "https://github.com/jamf/express"

  release_metadata = YAML.load(File.open(File.expand_path("../../metadata/express.yaml", __FILE__)).read)

  url release_metadata["url"]
  version release_metadata["version"]
  sha256 release_metadata["sha256"]

  def install
    bin.install "express-darwin"
    mv bin/"express-darwin", bin/"express"
  end

  test do
    system "#{bin}/express", "--help"
  end
end
