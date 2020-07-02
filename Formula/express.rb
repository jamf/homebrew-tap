class Express < Formula
  desc "A rapid application development toolset"
  homepage "https://github.com/jamf/express"

  release_yaml = <<~YAML
    version: "0.1.0"
    url: "https://github.com/jamf/express/releases/download/0.1.0/express-darwin"
    sha256: "5e77ac404f3d764dc7da734c383cd2548d3aa1a129a0d3c2d246b3bd91230b88"
  YAML

  release_metadata = YAML.load(release_yaml)

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
