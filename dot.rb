# Documentation: https://docs.brew.sh/Formula-Cookbook
#                https://rubydoc.brew.sh/Formula
# PLEASE REMOVE ALL GENERATED COMMENTS BEFORE SUBMITTING YOUR PULL REQUEST!
class Dot < Formula
  desc "dot is dotfiles manage cli."
  homepage "https://github.com/atsushi130/dot"
  url "https://github.com/atsushi130/dot/archive/v1.1.0.tar.gz"
  sha256 "0d676362f994a7fd31735fef0d36d5b9987034bfefdbe5008bb1744f2353b3ae"
  # depends_on "cmake" => :build

  def install
    bin.install "dot"
  end

  test do
    # `test do` will create, run in and delete a temporary directory.
    #
    # This test will fail and we won't accept that! For Homebrew/homebrew-core
    # this will need to be a test that verifies the functionality of the
    # software. Run the test with `brew test dot`. Options passed
    # to `brew install` such as `--HEAD` also need to be provided to `brew test`.
    #
    # The installed folder is not in the path, so use the entire path to any
    # executables being tested: `system "#{bin}/program", "do", "something"`.
    system "false"
  end
end
