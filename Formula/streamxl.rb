class Streamxl < Formula
  include Language::Python::Virtualenv
  desc "High-performance streaming XLSX reader for Python, powered by Rust"
  homepage "https://github.com/Mullassery/streamXL"
  license "MIT"
  version "0.4.0"
  # cp313 wheel — requires Python 3.13. Library only (no console script).
  # :nounzip keeps the .whl intact so it can be pip-installed offline.
  url "https://files.pythonhosted.org/packages/c0/60/f1b01f1277092302569ee6949cab21316f47f757acd0e15de621e82c3b36/streamxl-0.4.0-cp313-cp313-macosx_11_0_arm64.whl", using: :nounzip
  sha256 "99b4be1a2cff6fa2a1bed3b2dfc4aceb5099fa5de68dfcc12300f659eb68290a"

  depends_on "python@3.13"

  def install
    venv = virtualenv_create(libexec, "python3.13")
    venv.pip_install Dir[buildpath/"*.whl"].first
  end

  test do
    system libexec/"bin/python", "-c", "import streamxl; print('streamxl installed successfully')"
  end
end
