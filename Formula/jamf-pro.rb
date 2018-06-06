# Documentation: https://docs.brew.sh/Formula-Cookbook
#                http://www.rubydoc.info/github/Homebrew/brew/master/Formula
require 'json'

class JamfPro < Formula
  stable = JSON.parse(File.open(File.expand_path("../../jamf-pro/release.json", __FILE__)).read)
  snapshot = JSON.parse(File.open(File.expand_path("../../jamf-pro/snapshot.json", __FILE__)).read)
  # The official release
  url stable["url"], using: :nounzip
  version stable["version"]
  sha256 stable["sha256"]
  # Used for the latest passing Snapshots
  devel do
    url snapshot["url"], using: :nounzip
    version snapshot["version"]
    sha256 snapshot["sha256"]
  end

  desc "The Jamf | PRO CLI"
  homepage "https://www.jamf.com/products/jamf-pro/"
  # depends_on "cmake" => :build

  def install
    # Move to become jamf-pro and remove the system tag this will not be needed
    # latter
    mkdir_p bin
    mv "jamf-pro", "#{bin}/jamf-pro"
    chmod "a+x", "#{bin}/jamf-pro"

    # Install zsh completion to brews zsh/site-functions dir so that we get
    # autocompletion without messing with our zshrc
    zsh_comp_dir = "#{prefix}/share/zsh/site-functions"
    mkdir_p zsh_comp_dir
    File.new("#{zsh_comp_dir}/_jamf-pro", 'w').puts(%x(#{bin}/jamf-pro completion zsh))
  end

  test do
    # `test do` will create, run in and delete a temporary directory.
    #
    # This test will fail and we won't accept that! For Homebrew/homebrew-core
    # this will need to be a test that verifies the functionality of the
    # software. Run the test with `brew test jamf`. Options passed
    # to `brew install` such as `--HEAD` also need to be provided to `brew test`.
    #
    # The installed folder is not in the path, so use the entire path to any
    # executables being tested: `system "#{bin}/program", "do", "something"`.
    result = %x(#{bin}/jamf-pro --version)
    assert_match /^#{version}/, result
  end
end
