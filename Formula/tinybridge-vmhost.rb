class TinybridgeVmhost < Formula
  desc "TinyBridge VM host manager - Direct hypervisor control utility"
  homepage "https://github.com/Mullassery/TinyBridge"
  license "MIT"
  version "0.4.0"

  on_macos do
    on_intel do
      url "https://github.com/Mullassery/TinyBridge/releases/download/v0.4.0/tinybridge-vmhost-0.4.0-x86_64-apple-darwin.tar.gz"
      sha256 "3fbc97903e8567491a8f1a626310f2492fd15bc658d97740e1a27942f9ab2069"
    end
    on_arm do
      url "https://github.com/Mullassery/TinyBridge/releases/download/v0.4.0/tinybridge-vmhost-0.4.0-aarch64-apple-darwin.tar.gz"
      sha256 "3fbc97903e8567491a8f1a626310f2492fd15bc658d97740e1a27942f9ab2069"
    end
  end

  def install
    bin.install "tinybridge-vmhost"
  end

  test do
    system bin/"tinybridge-vmhost", "--version"
  end
end
