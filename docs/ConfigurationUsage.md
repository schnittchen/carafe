# Configuration and usage

## Configure distillery

You do not need to add distillery to your Mix file, since carafe already depends on it. Head over to the
[distillery documentation](https://hexdocs.pm/distillery/getting-started.html) and set everything up such that
you can create releases locally.

## Configure carafe

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

The `:application` variable must be the name of the top-level OTP application that is being deployed,
and other OTP apps to be deployed with it must be deps (possibly transitive).

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
host or the target nodes. See [here](customtasks.html) for details. There you can also find example
snippets for Phoenix and Ecto.


