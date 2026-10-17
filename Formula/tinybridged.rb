# frozen_string_literal: true

class Tinybridged < Formula
  desc "TinyBridge daemon and VM host - Linux environment manager backend"
  homepage "https://github.com/Mullassery/tinybridge"
  url "https://github.com/Mullassery/tinybridge/releases/download/v0.6.1/tinybridge-0.6.1-aarch64-apple-darwin.tar.gz"
  sha256 "ae8a95e8003a67c761ef68833864bf915becc71814311bbbb17942a6c6fd083b"
  license "Apache-2.0"

  depends_on macos: :ventura
  depends_on "tinybridge"

  disable! date: "2026-10-14", because: :unsupported unless Hardware::CPU.arm?

  def install
    # tinybridged itself has no dylib dependency and installs normally.
    bin.install "tinybridged"

    # As of v0.6.0 the vmhost is built with an @executable_path rpath
    # (crates/tinybridge-vmhost/build.rs upstream), so it finds
    # libTinyBridgeVZBridge.dylib next to itself with no
    # DYLD_LIBRARY_PATH wrapper or install_name_tool patch needed — just
    # keep them together.
    libexec.install "tinybridge-vmhost", "libTinyBridgeVZBridge.dylib"
    bin.install_symlink libexec/"tinybridge-vmhost"

    # tinybridge-vmhost requires the com.apple.security.virtualization
    # entitlement to call into Virtualization.framework. Ad-hoc signing
    # satisfies this for local use.
    entitlements = buildpath/"tinybridge-vmhost.entitlements"
    system "codesign", "--force", "--sign", "-",
           "--entitlements", entitlements.to_s,
           libexec/"tinybridge-vmhost"
  end

  service do
    run [opt_bin/"tinybridged"]
    keep_alive successful_exit: false
    log_path var/"log/tinybridge.log"
    error_log_path var/"log/tinybridge.log"
  end

  def caveats
    <<~EOS
      The daemon is installed but not started automatically. To start it now
      and on every login:
        brew services start tinybridged

      Logs: #{var}/log/tinybridge.log
    EOS
  end

  test do
    assert_match "tinybridge", shell_output("#{bin}/tinybridged --version")
  end
end
