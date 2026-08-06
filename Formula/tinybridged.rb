class Tinybridged < Formula
  desc "TinyBridge daemon - VM orchestration and management service"
  homepage "https://github.com/Mullassery/TinyBridge"
  license "MIT"
  version "0.4.0"

  on_macos do
    on_intel do
      url "https://github.com/Mullassery/TinyBridge/releases/download/v0.4.0/tinybridged-0.4.0-x86_64-apple-darwin.tar.gz"
      sha256 "1bfadc096019df8c4169b662ed79950f9e2a5c78dddd6a993c7acd63d84f5535"
    end
    on_arm do
      url "https://github.com/Mullassery/TinyBridge/releases/download/v0.4.0/tinybridged-0.4.0-aarch64-apple-darwin.tar.gz"
      sha256 "1bfadc096019df8c4169b662ed79950f9e2a5c78dddd6a993c7acd63d84f5535"
    end
  end

  def install
    bin.install "tinybridged"
  end

  service do
    run opt_bin/"tinybridged"
    keep_alive true
    log_path var/"log/tinybridged.log"
    error_log_path var/"log/tinybridged.error.log"
  end

  test do
    system bin/"tinybridged", "--version"
  end
end
