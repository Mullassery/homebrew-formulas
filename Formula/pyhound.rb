class Pyhound < Formula
  include Language::Python::Virtualenv
  desc "Rust retrieval diagnostics engine for Python"
  homepage "https://github.com/Mullassery/PyHound"
  license "MIT"
  # Published on PyPI as 'pyhound-core' (the bare 'pyhound' name is taken by an
  # unrelated project). The importable module remains 'pyhound'.
  url "https://files.pythonhosted.org/packages/37/27/1ce2dc6442fef047974d2a734441500b9c473788f9c8665ae011eac27a85/pyhound_core-0.1.0-cp313-cp313-macosx_11_0_arm64.whl"
  sha256 "24f3a120f264b60fdcbc5a055d3f9c4583ff644745b7988edc2c0108a4039625"
  version "0.1.0" # explicit: avoid Homebrew parsing "64" from arm64 in the URL

  depends_on "python@3.13"

  def install
    venv = virtualenv_create(libexec, "python3.13")
    venv.pip_install url
  end

  test do
    system libexec/"bin/python", "-c", "import pyhound; print('PyHound installed successfully')"
  end
end
