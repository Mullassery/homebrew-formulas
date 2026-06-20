class Prismnote < Formula
  include Language::Python::Virtualenv
  desc "Modern, open-source Jupyter-compatible data science notebook"
  homepage "https://github.com/Mullassery/prismnote"
  license "MIT"
  # 0.3.1 — pure-Python wrapper (py3-none-any). 0.3.0 was an empty broken wheel.
  url "https://files.pythonhosted.org/packages/ef/8e/cf04e70cb0528586e6af59b8d709a10769f0a616a3cf7aa6beac3c2dd155/prismnote-0.3.1-py3-none-any.whl"
  sha256 "4069b1e2d221ab16b51dafbb9066483b92767827be70d9a9f2d70d6ace417992"

  depends_on "python@3.11"

  def install
    venv = virtualenv_create(libexec, "python3.11")
    venv.pip_install "prismnote==0.3.1"
    bin.install_symlink libexec/"bin/prismnote"
  end

  test do
    # `prismnote --version` downloads/launches the server binary (needs network),
    # so just verify the package imports.
    system libexec/"bin/python", "-c", "import prismnote; print('prismnote OK')"
  end
end
