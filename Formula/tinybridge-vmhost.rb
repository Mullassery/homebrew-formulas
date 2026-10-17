# frozen_string_literal: true

class TinybridgeVmhost < Formula
  desc "TinyBridge VM host manager - Direct hypervisor control utility"
  homepage "https://github.com/Mullassery/tinybridge"
  url "https://github.com/Mullassery/tinybridge/releases/download/v0.6.1/tinybridge-0.6.1-aarch64-apple-darwin.tar.gz"
  sha256 "ae8a95e8003a67c761ef68833864bf915becc71814311bbbb17942a6c6fd083b"
  license "Apache-2.0"

  depends_on macos: :ventura

  # Only an arm64 build is published as of v0.6.1.
  disable! date: "2026-10-14", because: :unsupported unless Hardware::CPU.arm?

  def install
    # VM host must ship next to its dylib (@executable_path rpath) and be
    # ad-hoc signed with the Virtualization entitlement, otherwise it
    # fails at launch with a dylib-not-found / entitlement error.
    libexec.install "tinybridge-vmhost", "libTinyBridgeVZBridge.dylib"
    bin.install_symlink libexec/"tinybridge-vmhost"

    entitlements = buildpath/"tinybridge-vmhost.entitlements"
    system "codesign", "--force", "--sign", "-",
           "--entitlements", entitlements.to_s,
           libexec/"tinybridge-vmhost"
  end

  test do
    assert_match "tinybridge", shell_output("#{bin}/tinybridge-vmhost --version")
  end
end
