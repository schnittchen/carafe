## 0.1.2 (upcoming)

Major changes: With `execute_elixir`, we will be able to replace
edeliver functionality soo.

### Fixed

* Documentation referred to wrong versions
* Gem now depends on capistrano
* Release version extraction was affected by noise on stdout

### Added

* `:distillery_release` is now configurable in deployment config
* `execute_elixir` utility

### Changed

* partial overhaul of internal DSL
* better error messages
* improved documentation
* switched to CircleCI, build against multiple elixir versions

## 0.1.1

### Fixed

* The `deploy` rake task from capistrano is undefined at first, so users are in full control of this task
* The `node:full-restart` task now operates in the correct working directory
