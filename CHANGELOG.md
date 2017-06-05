## 0.1.2

### Fixed

* Documentation referred to wrong versions
* Gem now depends on capistrano

### Added

* `:distillery_release` is now configurable in deployment config

### Changed

* partial overhaul of internal DSL
* better error messages

## 0.1.1

### Fixed

* The `deploy` rake task from capistrano is undefined at first, so users are in full control of this task
* The `node:full-restart` task now operates in the correct working directory
