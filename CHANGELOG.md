# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

### Fixed
- Fixed wrong initiation of `CONV_HISTORY` and other globals that led to UndefVarError. Moved several globals to `const Ref{}` pattern to ensure type stability, but it means that from now it always needs to be dereferenced with `[]` (eg, `MAIN_INDEX[]` instead of `MAIN_INDEX`).

