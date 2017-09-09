# Carafe

[![Hex.pm](http://img.shields.io/hexpm/v/carafe.svg)](https://hex.pm/packages/carafe)
[![Build status](https://api.travis-ci.org/schnittchen/carafe.svg)](https://travis-ci.org/schnittchen/carafe)
[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/schnittchen/carafe/master/LICENSE.md)

This is a tool for deploying Elixir applications, built upon [capistrano](http://capistranorb.com/).

Carafe requires git for hosting the source repository. It depends on
[Edeliver](https://github.com/boldpoker/edeliver) for a few parts that are not handled in
Carafe yet. Release building requires [Distillery](https://github.com/bitwalker/distillery).

![Screenshot](https://github.com/schnittchen/carafe/blob/master/deploy.gif)

Currently, only full releases, not upgrades, are supported, and archives are
kept locally.

## Installation

### Prerequisites, Ruby side

You need ruby >= 2.0 installed in your development environment. The recommended way of installing dependencies on the ruby side is via bundler. Create a `Gemfile` at
the project root containing:

```
source "https://rubygems.org"

group :development do
  gem "carafe"
end
```

Then run `bundle install --path vendor/bundle`, followed by `bundle exec cap install`. This gives you
these additional files:

```
o .bundle/config
+ Capfile
+ Gemfile
+ Gemfile.lock
o vendor/bundle
+ config/deploy.rb
+ config/deploy/staging.rb
+ config/deploy/production.rb
```

Files behind `o` should be gitignored, the others checked in. In your `Capdfile`, add the following line
```
require "carafe"
```
below the line
```
require "capistrano/deploy"
```

### Prerequisites, Elixir side

Add these deps to your `mix.exs`:

```
  defp deps do
    [
      {:edeliver, "~> 1.4.2"},
      {:distillery, "~> 1.3.5"},
      {:carafe, "~> 0.1.1", app: false}
    ]
  end
```

and run `mix deps.get`. Add `:edeliver` to your `:extra_applications` AS LAST:

```
  def application do
    [extra_applications: [:logger, :edeliver]]
  end
```

## Configuration

First, configure your application for [distillery](https://github.com/bitwalker/distillery/).

The [Capistrano documentation on configuration](http://capistranorb.com/documentation/getting-started/configuration/)
gives you all the technical details on configuration in general. Note that Carafe does not use most of the
variables listed there. Below you find a short introduction that gets you started.

General configuration goes into `config/deploy.rb`. Capistrano has the concept of "stages", and stage specific
configuration goes into separate files. For the `production` stage this would be `config/deploy/production.rb`.
Stage specific configuration has precedence over general one.

To configure the deployment process, we mostly set variables and declare servers, as in this example snippet:

```
set :application, "my_app"
set :repo_url, "https://github.com/...."

set :repo_path, "dummy1_repo"
set :build_path, "build_path"
server "buildhost1", user: "user", roles: ["build"]
```

Note we are declaring a host (and how to connect to via ssh) to be a build host by giving it the "build" role.
There obviously must be only one buildhost. In `config/deploy/production.rb`, we might write

```
server "main", user: "user", roles: ["app"]
```

to declare a server as a node to deploy our app to.
Documentation on the `server`
options can be found [here](http://capistranorb.com/documentation/advanced-features/properties/).

Here are the config variables honored by carafe:

|Varible|Used for/as...|
|---|---|
|`:branch`| git branch to build the release from, or :current for current branch|
|`:repo_url`| cloning the repo on the build host|
|`:repo_path`| path of repository cache on build host|
|`:mix_env`| MIX_ENV environment when running `release` mix task from distillery|
|`:application`| name of the OTP application|
|`:distillery_environment`| name of the distillery environment, defaulting to the value of :mix_env|
|`:distillery_release`| name of the distillery release, defaulting to the value of :application|
|`:build_path`| path to build release on build host|
|`:app_path`| path on application server where releases are unpacked and operated|

### Umbrella project deployments

A demonstration for an umbrella project is in the `dummies/dummy2` test dummy project.

## Usage

Currently, only deploying releases is supported. Every deploy scenario is a bit different, so
you need to tell how a deploy is to be done. In `deploy.rb`, add the following line:

```
task "deploy" => [
  "buildhost:generate_release",
  "buildhost:archive:download",
  "node:archive:upload_and_unpack",
  "node:full_restart"
]
```

You should now be able to perform a production deploy with the command `bundle exec cap production deploy`.

## Custom tasks

Custom tasks can be written to be executed before and after other tasks on the build
host or the target nodes. See [here](customtasks.html) for details.

## Development & Contributing [(link)](contributing.html)

**Don't run tests on your development machine**

