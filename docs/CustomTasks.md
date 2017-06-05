# Custom tasks

## Simple examples

Let's write a simple custom task:

```
task :add_to_priv do
  on build_host do |host|
    within build_path do
      execute :mkdir, "-p", "priv"
      execute :cp, "/etc/hostname", "priv/"
    end
  end
end
```

While not being terribly useful, this gives you an idea of what we can do:
At some point in time, on the build host within the build path,
we create the `priv` directory and copy `/etc/hostname` into it.

If we make this happen before distillery's `release` mix task runs, the file
will be part of the application in the release (that's what `priv` is for). So let's do just that:

```
before "buildhost:mix:release", :add_to_priv
```

Custom tasks can be useful even when they are not part of the normal deploy
process. Administrative tasks being executed on the target nodes can be executed
through capistrano. Let's write an example:

```
desc "Does hosekeeping on the node yadda yadda"
task "node:janitor" do
  on app_hosts do |host|
    within app_path do
      # do some janitorial task here
    end
  end
end
```

Now you can enter `bundle exec cap staging node:janitor` to have the task executed on all
staging nodes.

The `desc` line adds documentation to your task that will appear when you run `bundle exec cap -T`.

NOTE you cannot use mix tasks here because they are not part of the code available on a node.

## Available API

For the general mechanics of executing commands (with environment, in a path, in parallel) or
up/downloading files please see the
[SSHKit documentation](https://github.com/capistrano/sshkit/blob/master/README.md). Capistrano
includes the DSL from SSHKit to make all of this available for us.

For the Carafe-specific parts of the DSL, head over to
[the implementation of the `Carafe::DSL` module](https://github.com/schnittchen/carafe/blob/master/lib/carafe.rb)
where you can find all available methods documented.

## Where to put custom tasks and where to trigger them

When you have only 1-2 short custom tasks, you can keep them in `config/deploy.rb`.
Otherwise, put them into a file matching the pattern `lib/capistrano/tasks/*.rake`, and they will automatically be available.

Use `before` or `after` hooks only from `config/deploy.rb`, not from a `.rake` file,
and avoid placing hooks in a stage config file.

