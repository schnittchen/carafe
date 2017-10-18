# Carafe

[![Hex.pm](http://img.shields.io/hexpm/v/carafe.svg)](https://hex.pm/packages/carafe)
[![Build status](https://circleci.com/gh/schnittchen/carafe/tree/master.svg?style=shield&circle-token=196cd3a80a40aabb92eb48e005fd12230ccf5dbb)](https://circleci.com/gh/schnittchen/carafe)
[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/schnittchen/carafe/master/LICENSE.md)

This is a tool for deploying Elixir applications, built upon [capistrano](http://capistranorb.com/).

Carafe requires git for hosting the source repository. It depends on
[Distillery](https://github.com/bitwalker/distillery) for handling releases.

![Screenshot](https://github.com/schnittchen/carafe/blob/master/deploy.gif)

Currently, only full releases, not upgrades, are supported, and archives are
kept locally.

## Documentation and getting started

The official documentation can be found on [hex.pm](https://hexdocs.pm/carafe). The documentation
for the branch you are viewing starts [here](docs/GettingStarted.md).

## Development & Contributing [(link)](docs/Contributing.md)

**Don't run tests on your development machine**

