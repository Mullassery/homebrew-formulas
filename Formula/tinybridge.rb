class Tinybridge < Formula
  desc "Production-grade virtual machine platform with cross-platform support"
  homepage "https://github.com/Mullassery/TinyBridge"
  license "Apache-2.0"
  version "0.4.0"

  on_macos do
    on_intel do
      url "https://github.com/Mullassery/TinyBridge/releases/download/v0.4.0/tinybridge-0.4.0-x86_64-apple-darwin.tar.gz"
      sha256 "37f841ca835b203276e11e48666a11ad2f8ff197d218f26887c6e749b84421ed"
    end
    on_arm do
      url "https://github.com/Mullassery/TinyBridge/releases/download/v0.4.0/tinybridge-0.4.0-aarch64-apple-darwin.tar.gz"
      sha256 "37f841ca835b203276e11e48666a11ad2f8ff197d218f26887c6e749b84421ed"
    end
  end

  def install
    bin.install "tinybridge"
  end

  test do
    system bin/"tinybridge", "--version"
  end
end
