class Streamxl < Formula
  include Language::Python::Virtualenv
  desc "High-performance streaming XLSX reader for Python, powered by Rust"
  homepage "https://github.com/Mullassery/streamXL"
  license "MIT"
  version "0.1.0"
  # cp313 wheel — requires Python 3.13. Library only (no console script).
  # :nounzip keeps the .whl intact so it can be pip-installed offline.
  url "https://files.pythonhosted.org/packages/b8/3f/f95edee0f92b4f9628cd7424efb540c75921d348c5e5302ebc7b15666ada/streamxl-0.1.0-cp313-cp313-macosx_11_0_arm64.whl", using: :nounzip
  sha256 "b3676f7da16ba20232991c7103228c52b3c622b29bd07080cc05e555b1662a2a"

  depends_on "python@3.13"

  def install
    venv = virtualenv_create(libexec, "python3.13")
    venv.pip_install Dir[buildpath/"*.whl"].first
  end

  test do
    system libexec/"bin/python", "-c", "import streamxl; print('streamxl installed successfully')"
  end
end
