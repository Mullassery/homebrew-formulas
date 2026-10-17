# homebrew-formulas

[![Graphify](https://img.shields.io/badge/Graphify-knowledge%20graph-blue)](https://github.com/Graphify-Labs/graphify)

Legacy, deprecated combined Homebrew tap for Georgi Mullassery's open-source
tools. It has been superseded by two maintained partial taps:

- [`Mullassery/homebrew-prismnote`](https://github.com/Mullassery/homebrew-prismnote) — `prismnote`
- [`Mullassery/homebrew-tinybridge`](https://github.com/Mullassery/homebrew-tinybridge) — `tinybridge`, `tinybridged`

## Usage

```bash
brew tap Mullassery/homebrew-formulas
brew install <formula>
```

## Formulae

This tap ships the following formulas. They are not all PyPI virtualenvs:

- `prismnote` — Jupyter-compatible notebook (PyPI wheel, Python virtualenv)
- `streamxl` — streaming XLSX reader (arm64-only PyPI wheel, Python virtualenv)
- `clusteraudiencekit` — audience segmentation engine (arm64-only PyPI wheel, Python virtualenv)
- `pyhound` — RAG/LLM retrieval diagnostics (arm64-only PyPI wheel, Python virtualenv)
- `tinybridge`, `tinybridged`, `tinybridge-vmhost` — TinyBridge CLI, daemon, and VM host (prebuilt release tarballs)

The Rust-backed formulas (`streamxl`, `clusteraudiencekit`, `pyhound`) publish
arm64-only wheels and refuse to install on Intel Macs.

## Notes

- Prefer the maintained partial taps above; this combined tap is kept for
  backward compatibility only.

## License

Each formula and tool is licensed under its own project's terms: the TinyBridge
formulas are Apache-2.0; see the individual formula for the rest.
