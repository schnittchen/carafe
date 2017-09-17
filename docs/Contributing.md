# Development and Contributing

## Running the tests

**WARNING** Running the tests involves killing processes and switching user identity.

**Don't run tests on your development machine**

The project uses [Circle CI](https://circleci.com/gh/schnittchen/carafe). For running tests
locally, you need to set up a virtual machine. The easiest road is using Vagrant.

One you are inside the virtual machine, you can execute the tests just with `mix test`.

### Setting up a Vagrant machine

If you haven't already, [install Vagrant](https://www.vagrantup.com/downloads.html).

Then, inside the directory root of the project, run

```
vagrant up
```

You can then enter the machine with `vagrant ssh`.

Inside the machine, first up you need to install a recent ruby version and then replicate
the setup steps in the `circle.yml` file once.

You can execute a single test file with
`vagrant ssh -- sh -c "cd /vagrant; mix test test/some_test.exs"`.

### Setting up an LXC container with LXD

This only works on a linux machine, but has performance benefits, which can be useful for
triggering race conditions that don't surface when using Vagrant. The setup is a little bit
involved, so I'm only mentioning it here for now.

