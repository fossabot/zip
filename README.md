![Zip Logo](https://raw.githubusercontent.com/zip-lang/media/main/logo-128x128.png)

[![FOSSA Status](https://app.fossa.com/api/projects/git%2Bgithub.com%2Fzip-lang%2Fzip.svg?type=shield)](https://app.fossa.com/projects/git%2Bgithub.com%2Fzip-lang%2Fzip?ref=badge_shield)
[![Codacy Badge](https://app.codacy.com/project/badge/Grade/3c04af6c37ef43ca958efd9cbed0e1df)](https://www.codacy.com/gh/zip-lang/zip/dashboard?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=zip-lang/zip&amp;utm_campaign=Badge_Grade)

A modern programming language from the future, just for fun.

Zip is a new programming language, currently under active development.
It's a modern, statically-typed functional and runs on the BEAM (Erlang VM), but focusing in building and maintaining scalable web apps without compromising on programmer ergonomics.

Project status: Actively developed. Not ready for production use or HackerNews.

### Syntax

Here's a quick walkthrough of Zip's syntax.

#### Functions

A function in Zip looks like this:

```elixir
# example.zp
fn sum(a: Int, b: Int) : Int do
  a + b
end
```

This is a function named `sum` which takes two integers and returns another integer.
Identifiers in Zip are written in snake_case (similar to Ruby, Elixir or Python).
Types are written in CamelCase.

Zip has a type checker which makes sure your functions actually return what
they say they do. For example, the type checker will report an error for
the following code:

```elixir
fn sum(a: Int, b: Int) : Float do
  a + b
end

# Error: "Expected type: Float, got: Int"
```

All functions in Zip are nested inside modules.
Module names in Zip are inferred from their file paths, so a Zip file named
`example.zp` will become a module named `example`. All functions inside this
file will belong to this module.

The `sum` function can be called like so:

```elixir
# Calling locally within the module
sum(40, 2)

# Calling remotely outside the module
example.sum(40, 2)
```

#### If-Else expressions
An if-else expression in Zip looks like this:
```
if true do
  a = "we have if-else now!"
  200
else
  404
end
```

#### Basic types and operators

Zip is currently a proof of concept so its data types and operators are quite
limited.

Data types - atoms, integers, strings, booleans, lists and records.
Operators - assignment(=), logical(&, |, !) and arithmetic(+, -, *, /).

```elixir
# This is a comment

# Type: Int
a = 40
b = 2
c = a + b

# Type: String
str = "Hello world"

# Type: Bool
x = true

# Type: List(Int)
list_of_ints = [1, 2, 3]

# Type: {String,Bool}
tuple = {"tuple", true}

# Type: {foo: Int}
record = {foo: 123}
```

[example.zp](https://github.com/zip-lang/zip/blob/main/example.zp) has
working examples that demonstrate the syntax.

### Running Zip programs

Zip is written in Elixir, so make sure you have that installed.
Follow [these instructions](https://elixir-lang.org/install.html) to install
Elixir. Next, clone this repo, cd into the directory and then follow the below instructions.

#### Using Elixir shell

```
# Install dependencies and run the Elixir shell
mix deps.get
iex -S mix

# In the Elixir shell, compile and load a Zip file using the following:
> Zip.Code.load_module("example")

# Now you can run functions from the module like this:
> :example.sum(40, 2)
> 42
```

#### Using `zip` executable

```
# Create the executable
mix escript.build

# Call the function example.sum(1, 2) from the file example.zp
./zip exec --function="sum(1, 2)" example.zp
```

### Your first HTTP server

Zip comes with a webserver which allows you to quickly create HTTP request
handlers. By default, Zip looks for routes in a function called
`router.routes()`, so you need to define that first:

Note: This webserver is a prototype for now and only responds with strings and
a 200 status code.

```elixir
# Inside router.zp
fn routes : List({method: String, path: String, handler: Fn(->String)}) do
  [
    {method: "GET", path: "/", handler: &greet}
  ]
end

fn greet : String do
  "Hello world"
end
```

Now start the webserver in one of two ways:

#### Using Elixir shell

```
# router.zp is in the `examples` folder
> Zip.start("examples")

# Reload routes after changing routes.zp
> Zip.RouteStore.reload_routes()
```

#### Using `zip` executable

```
# Create the executable
mix escript.build

# router.zp is in the `examples` folder
./zip start examples

# Re-run the command after making changes to routes.zp
```

Now open `http://localhost:6060` in the browser to see "Hello world" served
by Zip.

## Contributing

Please make sure to read the [CONTRIBUTING-Guidelines](https://github.com/zip-lang/zip/blob/main/CONTRIBUTING.md) before making a pull request.

Thank you to all the people who already contributed to Zip!

<a href="https://github.com/zip-lang/zip/graphs/contributors">
  <img src="https://contributors-img.firebaseapp.com/image?repo=zip-lang/zip" />
</a>

## License

Apache-2.0

[![FOSSA Status](https://app.fossa.com/api/projects/git%2Bgithub.com%2Fzip-lang%2Fzip.svg?type=large)](https://app.fossa.com/projects/git%2Bgithub.com%2Fzip-lang%2Fzip?ref=badge_large)