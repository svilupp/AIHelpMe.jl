# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

### Fixed

## [0.4.0]

### Added
- Added the knowledge pack for GenieFramework org. (alias `:genie`).

### Updated
- Updated the knowledge pack for core Julia docs (alias `:julia`).

Both were made possible by [Splendidbug](https://github.com/splendidbug)!

## [0.3.0]
### Added (thanks to [Splendidbug](https://github.com/splendidbug)!)
- New knowledge packs created by Splendidbug using `DocsScraper.jl` (to be registered soon, created as part of Google Summer of Code).
- Knowledge packs for JuliaData org (DataFrames.jl), Plots org, and SciML org.
- Refreshed knowledge packs for Makie org and Tidier org.
- Golden Q&A sets for new packages to evaluate performance.

### Changed
- Changed default chunk size to 384 based on evaluation results.
- Increased compatibility for PromptingTools to v0.50, enabling the use of the latest chat models.
- Changed const-Ref variables to typed globals to prevent issues encountered in PromptingTools.

### Removed
- Legacy pack "juliaextra".

### Fixed
- Issues related to const-Ref variables by switching to typed globals.
- Fixed `:gold` pipeline inconsistently updating the embedding dimension

### Notes
- The new knowledge packs are currently available only for the OpenAI Text embedding Large 3 model.
- Latest chat models can now be used, but embedding models are restricted for prebuilt knowledge packs.

## [0.2.1]

### Updated
- Increased compat for PromptingTools to v0.37.1 to include bug fixes.
 

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

