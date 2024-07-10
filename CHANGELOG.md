# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

### Fixed

## [0.2.1]

### Updated
- Increased compat for PromptingTools to v0.37.1 to include bugfixes.
 

## [0.2.0]

### Updated
- Increased compat for PromptingTools to v0.37

## [0.1.1]

### Fixed
- Fixed a bug in `build_index` where imports were missing and keywords were not passed properly in all scenarios.

## [0.1.0]

### Added
- (Preliminary) Knowledge packs available for Julia docs (`:julia`), Tidier ecosystem (`:tidier`), and Makie ecosystem (`:makie`). Load with `load_index!(:julia)` or several with `load_index!([:julia, :tidier])`.
- Preferences.jl-based persistence for chat model, embedding model, embedding dimension, and which knowledge packs to load on start. See `AIHelpMe.PREFERENCES` for more details.
- Precompilation statements to improve TTFX.
- First Q&A evaluation dataset in folder `evaluations/`.

### Changed
- Bumped up PromptingTools to v0.21 (brings new RAG capabilities, pretty-printing, etc.)
- Changed default model to be GPT-4 Turbo to improve the answer quality (you can quickly change to "gpt3t" if you want something simple)
- Documentation moved to Vitepress

### Fixed
- Fixed wrong initiation of `CONV_HISTORY` and other globals that led to UndefVarError. Moved several globals to `const Ref{}` pattern to ensure type stability, but it means that from now it always needs to be dereferenced with `[]` (eg, `MAIN_INDEX[]` instead of `MAIN_INDEX`).

