# Configuration and usage

## Configure distillery

You do not need to add distillery to your Mix file, since carafe already depends on it. Head over to the
[distillery documentation](https://hexdocs.pm/distillery/getting-started.html) and set everything up such that
you can create releases locally.

## Configure carafe

### Concepts

When you use carafe to deploy a release, you will enter something like this into a shell:

```
bundle exec cap production deploy
```

Here, `production` is a "stage" and `deploy` is a task to be executed.

<dl>
<dt>Task</dt>
<dd>
Something to be achieved, for example by executing commands on a server or locally.
</dd>

<dt>Stage</dt>
<dd>
In what context something is to be done. This usually means a set of servers to consider and some configuration
regarding build and deploy parameters. Typical stages are "staging" and "production".
</dd>

<dt>Host or Server</dt>
<dd>
A remote machine that can be accessed via ssh.
</dd>

<dt>Host role</dt>
<dd>
A logical grouping of hosts, via tagging.
Tasks can run commands on all hosts with a given tag.
</dd>

<dt>Hook</dt>
<dd>
Makes another task run before or after a given task.
</dd>

</dl>

For carafe, one host must be the "build" host. Hosts where a release is deployed to are called nodes.

### Where configuration goes

Capistrano configuration and tasks are written in Ruby.

Technically, a stage is defined by a file of the same name, which is loaded after the default configuration
such that it can add to it or overwrite settings. So the command

```
bundle exec cap production deploy
```

will first load `config/deploy.rb` with general configuration, then `config/deploy/production.rb` with everything
concerning the production stage.

Inside a stage file, you will typically define hosts and set variables for stage specific settings.

Put shared configuration and host definitions into `config/deploy.rb`. Hooks should only go into this file.

### Tasks and hooks

Both capistrano and carafe come with pre-defined tasks.

Tasks can have a body of code, other tasks as dependencies, or both.
Dependencies are executed in order before the body is executed, allowing for
simple sequence workflows. Task bodies are blocks of Ruby code that can declare commands to be [executed
on remote hosts](http://capistranorb.com/documentation/getting-started/tasks/) or
[locally](http://capistranorb.com/documentation/getting-started/local-tasks/).

Adding this to `config/deploy.rb` will enable a simple standard deploy workflow with carafe:

```
task "deploy" => [
  "buildhost:generate_release",
  "buildhost:archive:download",
  "node:archive:upload_and_unpack",
  "node:full_restart"
]
```

This "deploy" task has no body and depends on a couple of tasks defined by carafe. To make them
work, you need to set a couple of variables, see below.

You can declare a task to be always executed before or after another one, this is called a hook.
This makes it easy to extend a deployment workflow with additional steps.

### Server declarations

This declaration

```
server "buildhost1", user: "user", roles: ["build"]
```

tells capistrano that the host "buildhost" has the "build" role, and that it should ssh to it
using the "user" user.

Use the role "app" role for node hosts.

There are two ways of declaring servers in capistrano. Check
[this tutorial](http://capistranorb.com/documentation/getting-started/preparing-your-application/)
for details. See [here](http://capistranorb.com/documentation/advanced-features/properties/)
for connection options.

### Configuration variables

In this snippet, we set a number of variables used by carafe tasks.

```
set :application, "my_app"
set :repo_url, "https://github.com/...."

set :repo_path, "dummy1_repo"
set :build_path, "build_path"
```

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

### Custom tasks, Phoenix and Ecto applications

Carafe currently provides no tasks for Phoenix and Ecto, however you can add these easily.
You can choose to add them as steps to your standard deploy task, or use hooks to have them
executed at the right time.

See [here](customtasks.html) for examples and snippets.

## Usage

You have already seen commands for basic deploys, making use of a "deploy" task as defined in
a snipped above.

It is worth mentioning that you can pass more than one task to capistrano:

```
bundle exec cap staging node:start node:attach
```

Why the `bundle exec`? This wraps the `cap` invocation in Ruby's standard package manager,
[bundler](https://bundler.io/). This way, carafe (the Ruby gem) and its dependencies
will always run with the versions captured in the `Gemfile.lock` file.

### Upgrading carafe

Both the `carafe` hex package and the gem will always have identical versions, and should
be upgraded together. This should do it:

```
bundle update carafe
mix deps.unlock carafe
mix deps.get carafe
```

Compare the versions of the gem and the hex package being fetched. If they don't match,
undo the changes to the lock files and try again with a different version constraint in your
`mix.exs`.

