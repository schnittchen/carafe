## 0.1.2 (upcoming)

Major changes: carafe no longer relies on edeliver for node services.

### Fixed

* Documentation referred to wrong versions
* Gem now depends on capistrano
* Release version extraction was affected by noise on stdout

### Added

* `:distillery_release` is now configurable in deployment config
* `execute_elixir` utility
* task snippets in documentation

### Changed

* partial overhaul of internal DSL
* better error messages
* improved documentation
* switched to CircleCI, build against multiple elixir versions
* monitoring application boot up no longer relies on edeliver.
* (breaking change) For umbrella applications, the `:application`
  variable must be the top app to be deployed

## 0.1.1

### Fixed

* The `deploy` rake task from capistrano is undefined at first, so users are in full control of this task
* The `node:full-restart` task now operates in the correct working directory
