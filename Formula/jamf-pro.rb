# Documentation:
# - https://docs.brew.sh/Formula-Cookbook
# - http://www.rubydoc.info/github/Homebrew/brew/master/Formula

require 'json'

class JamfPro < Formula
  release = JSON.parse(File.open(File.expand_path("../../jamf-pro/release.json", __FILE__)).read)
  snapshot = JSON.parse(File.open(File.expand_path("../../jamf-pro/snapshot.json", __FILE__)).read)

  # The official release
  url release["url"], using: :nounzip
  version release["version"]
  sha256 release["sha256"]

  # Used for the latest passing snapshots
  devel do
    url snapshot["url"], using: :nounzip
    version snapshot["version"]
    sha256 snapshot["sha256"]
  end

  desc "The Jamf Pro CLI"
  homepage "https://www.jamf.com/products/jamf-pro/"

  def install
    # Move CLI to bin directory and make executable
    mkdir_p bin
    mv "jamf-pro", "#{bin}/jamf-pro"
    chmod "a+x", "#{bin}/jamf-pro"

    # Install zsh completion to brew's zsh/site-functions dir so that we get
    # autocompletion without messing with our zshrc
    zsh_comp_dir = "#{prefix}/share/zsh/site-functions"
    mkdir_p zsh_comp_dir
    File.new("#{zsh_comp_dir}/_jamf-pro", 'w').puts(%x(#{bin}/jamf-pro completion zsh))

    # Install bash completion to brew's etc/bash_completion.d dir so that we get
    # autocompletion without messing with our bashrc or bash_profile
    bash_comp_dir = "#{prefix}/etc/bash_completion.d"
    mkdir_p bash_comp_dir
    File.new("#{bash_comp_dir}/jamf-pro", 'w').puts(%x(#{bin}/jamf-pro completion bash))
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
    assert_match /^\d+\.\d+\.\d+/, result
  end
end
