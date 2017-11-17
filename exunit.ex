
# ExUnit Quick Reference

# ExUnit is a unit testing framework that comes bundled with Elixir.

# Elixir is a functional and concurrent language built on top of Erlang so it only makes sense to offer a testing framework that unlocks all of the powerful features of the language.

# The goal of this quick reference is to demonstrate the main features of ExUnit as well as some real-world examples to get you ready to use ExUnit quickly.

#Table of Contents
#
#Setup
#Example
#Running
#Assertions
#Setup And Exit
#Tags
#Mix Test.Watch
#Resources
#Setup
#
# First, we will want to setup our test helper and start ExUnit. This file should live under the test directory.

#test_helper.exs

ExUnit.start()

#That’s all that is required to start using ExUnit. If you want further configuration options, ExUnit has an ExUnit.configure function that allows you to set up exclusions, formatters, etc.

# Basic Example

# The most basic example, as shown in the official ExUnit docs, is to assert the truth. We can write a simple test to make this assertion as such:

defmodule AssertionTest do
  use ExUnit, async: true

  test "the truth" do
    assert true
  end
end

#If you are experienced with other testing framework, one line that might stand out is: use ExUnit, async: true. The async: true tells ExUnit to run this test case concurrently with other cases. As the docs point out, all of the tests in this specific module, however, are still run serially.
#
#Running
#
#To run your full test suite:

# mix test


# To run an individual file:

#mix test test/models/post_test.exs
#To run an individual test starting on line 123:

#mix test test/models/post_test.exs:123

# Assertions

# Let’s look at the assertion functions available to you as you test your application with ExUnit. In most cases you can switch between assert for positive assertions and refute for negative assertions.

# Assertion	Example

assert	assert foo == bar
assert (with default message)	assert foo == bar, "Womp"
assert_in_delta	assert_in_delta 1, 2, 1
assert_raise	assert_raise ArithmeticError, fn -> 1 + "test" end
assert_raise (with default message)	assert_raise ArithmeticError, "WOMP", fn -> 1 + "test" end
assert_receive	assert_receive :hello, 20_00
assert_received	assert_received :bye
catch_error	assert catch_error(error 1) == 1
catch_exit	assert catch_exit(exit 1) == 1
catch_throw	assert catch_throw(throw 1) == 1
flunk	flunk "This should raise an error"
refute	refute false
refute (with default message)	refute  false, "WOMP"
refute_in_delta	refute_in_delta 10, 11, 2
refute_receive	refute_recieve :hello, 20_000
refute_received	refute_recieved :bye

#Setup/Exit

#The ExUnit.Callbacks module defines a number of helpful callbacks we can use to setup context before our tests and tear down context after our test completes.

# on_exit

on_exit fn ->
  IO.puts "This is invoked once the test is done."
end

# setup

setup do
  IO.puts "This is run before each test"
  :ok
end

# setup with context

setup %{login_as: username} do
  IO.puts "Welcome: #{username}"
  [username: username]
end

# setup_all

setup_all do
  IO.puts "This is only run once."
  [login_as: "david"]
end

# setup_all with context

setup_all %{login_as: username} do
  IO.puts "This is only run once"
  [username: username]
end
start_supervised

{:ok, _} = start_supervised(MyServer)
stop_supervised

:ok = stop_supervised(MyServer)
Basic Example

defmodule MyTest do
  use ExUnit.Case, async: true

  setup do
    on_exit fn ->
      IO.puts "Exited from Process: #{inspect self()}"
    end

    [message: "Cheers"]
  end

  test "my message", %{message: message} do
    assert message == "Cheers"
  end
end

#Tags

#With ExUnit, you can tag tests in a number of different ways, with one of the most common being pending. If you want to tag a test as pending (which gets automatically skipped by mix test, you can apply the tag before the test:

@tag :pending
test "not done yet" do
  assert foo == bar
end

     # The other primary behavior tags that come with ExUnit are:

# Tag	Behavior
#capture_log	Log messages generated during the individual test if capture_log is not set globally to true
#skip	Skips the individual test
#timeout	Customize the timeout in milliseconds for the test
#report	Includes the provided tags on error reports. See example below
#Reporting Tags

#The report tag allows you to add elements to the error output

defmodule MyTest do
  @moduletag report: [:role]

  @tag role: "SuperAdmin"
  test "my test" do
    flunk "womp"
  end
end

     #A failing test in this situation would add this extra helpful information to the overall error output:

1) my test
   test/my_test.exs
   code: flunk "womp"
   stacktrace:
     test/my_test.exs
   tags:
     role: "SuperAdmin"
# Mix Test.Watch

#         https://github.com/lpil/mix-test.watch

#To be fair, this doesn’t come packaged with ExUnit, but this is easily one of my favorite testing tools for Elixir. By adding this tool to your dependencies in mix.exs, you can run:

mix test.watch [optional file path]
#and your test suite (or file) will automatically run each time you save a file. It also supports a --stale option that will only run tests which reference modules have changed since the last run. Epic. If you like TDD (and even if you don’t), this tool is a must.
