# Development and Contributing

## Running the tests

**WARNING** Running the tests involves killing processes and switching user identity.

**Don't run tests on your development machine**

The project uses [Travis CI](https://travis-ci.org/schnittchen/carafe). For running tests
locally, you need to set up a virtual machine. The easiest road is using Vagrant.

One you are inside the virtual machine, you can execute the tests just with `mix test`.

### Setting up a Vagrant machine

If you haven't already, [install Vagrant](https://www.vagrantup.com/downloads.html).

Then, inside the directory root of the project, run

```
vagrant up
```

You can then enter the machine with `vagrant ssh`. You can execute a single test file with
`vagrant ssh -- sh -c "cd /vagrant; mix test test/some_test.exs"`.

### Setting up an LXC container with LXD

This only works on a linux machine, but has performance benefits, which can be useful for
triggering race conditions that don't surface when using Vagrant. The setup is a little bit
involved, so I'm only mentioning it here for now.

### Travis CI setup

The machine used in CI needs to be prepared before the tests can run. This setup is shared
with the Vagrant machine, so keep this in mind when modifying `.travis-setup.sh`.
