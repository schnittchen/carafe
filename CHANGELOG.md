## 0.1.2 (upcoming)

### Fixed

* Documentation referred to wrong versions
* Gem now depends on capistrano
* Release version extraction was affected by noise on stdout

### Added

* `:distillery_release` is now configurable in deployment config

### Changed

* partial overhaul of internal DSL
* better error messages
* improved documentation
* switched to CircleCI, build against multiple elixir versions

## 0.1.1

### Fixed

* The `deploy` rake task from capistrano is undefined at first, so users are in full control of this task
* The `node:full-restart` task now operates in the correct working directory
