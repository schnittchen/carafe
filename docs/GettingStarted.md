# Getting started

## Elixir side

Add carafe as a dep to your `mix.exs`:

```
  defp deps do
    [
      {:carafe, "~> 0.1.1"}
    ]
  end
```

and run `mix deps.get`.

## Ruby side

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

Continue with the [configuration](./configurationusage.html) section.
