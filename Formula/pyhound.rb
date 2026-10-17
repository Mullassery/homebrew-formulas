class Pyhound < Formula
  include Language::Python::Virtualenv
  desc "Rust retrieval diagnostics engine for Python"
  homepage "https://github.com/Mullassery/PyHound"
  license "MIT"
  version "0.1.0"
  # Published on PyPI as 'pyhound-core' (the bare 'pyhound' name is taken by an
  # unrelated project). The importable module remains 'pyhound'.
  # :nounzip keeps the .whl intact so it can be pip-installed offline.
  url "https://files.pythonhosted.org/packages/37/27/1ce2dc6442fef047974d2a734441500b9c473788f9c8665ae011eac27a85/pyhound_core-0.1.0-cp313-cp313-macosx_11_0_arm64.whl", using: :nounzip
  sha256 "24f3a120f264b60fdcbc5a055d3f9c4583ff644745b7988edc2c0108a4039625"

  depends_on "python@3.13"

  # Only an arm64 wheel is published upstream — fail cleanly on Intel.
  disable! date: "2026-10-14", because: :unsupported unless Hardware::CPU.arm?

  def install
    venv = virtualenv_create(libexec, "python3.13")
    venv.pip_install Dir[buildpath/"*.whl"].first
  end

  test do
    system libexec/"bin/python", "-c", "import pyhound; print('PyHound installed successfully')"
  end
end
