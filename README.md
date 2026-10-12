# homebrew-tap

[![Graphify](https://img.shields.io/badge/Graphify-knowledge%20graph-blue)](https://github.com/Graphify-Labs/graphify)

Homebrew formulae for Georgi Mullassery's open-source tools.

## Usage

```bash
brew tap Mullassery/tap
brew install streamxl # streaming XLSX reader (Rust)
brew install clusteraudiencekit # audience segmentation engine (Rust)
brew install pyhound # RAG/LLM retrieval diagnostics (Rust)
brew install prismnote # Jupyter-compatible notebook
```

Each formula installs the package from PyPI into an isolated virtualenv.

## Notes

- `streamxl`, `clusteraudiencekit`, and `pyhound` ship cp313 wheels and depend on `python@3.13`.
- `prismnote` is a pure-Python wrapper (`python@3.11`).
- `statguard` will be added once it is published to PyPI.

## License

Formulae: MIT. Each tool is MIT-licensed; see its repository.
