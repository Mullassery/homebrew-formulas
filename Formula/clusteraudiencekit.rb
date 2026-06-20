class Clusteraudiencekit < Formula
  include Language::Python::Virtualenv
  desc "High-performance audience segmentation engine with Python bindings"
  homepage "https://github.com/Mullassery/clusteraudiencekit"
  license "MIT"
  # cp313 wheel — requires Python 3.13. Library only (no console script).
  url "https://files.pythonhosted.org/packages/10/01/32ce1b1a1003a4d3fbc35d48bca50602b59d73b2a0dfae9e24aa41523288/clusteraudiencekit-0.1.0-cp313-cp313-macosx_11_0_arm64.whl"
  sha256 "9b9c3ce34c58feb2bb8ba5ea5c4d4f653f2d62bc11186f22cff16d85904a075e"
  version "0.1.0" # explicit: avoid Homebrew parsing "64" from arm64 in the URL

  depends_on "python@3.13"

  def install
    venv = virtualenv_create(libexec, "python3.13")
    venv.pip_install "clusteraudiencekit==0.1.0"
  end

  test do
    system libexec/"bin/python", "-c", "import clusteraudiencekit; print('clusteraudiencekit installed successfully')"
  end
end
