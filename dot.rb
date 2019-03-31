# Documentation: https://docs.brew.sh/Formula-Cookbook
#                https://rubydoc.brew.sh/Formula
# PLEASE REMOVE ALL GENERATED COMMENTS BEFORE SUBMITTING YOUR PULL REQUEST!
class Dot < Formula
  desc "dot is dotfiles manage cli."
  homepage "https://github.com/atsushi130/dot"
  url "https://github.com/atsushi130/dot/archive/v1.0.0.tar.gz"
  sha256 "ce11ec3590c4a33118a41d2f07c38c85311528c20150743030b3a1f9a7c8acf4"
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
