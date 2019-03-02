# Context pattern

This gem gives you the scaffolding needed to easily use the Context Pattern in
your Ruby on Rails application

## What is the context pattern?

The context pattern provides a way of thinking about and writing Rails
applications that results in better code that is easier to maintain. This is
done through the introduction of a new category of object known as a Context
Object.

A Context Object is responsible for interpreting the current state of the
request, providing the context for a controller to do its work, and defining an
interface that may be referenced by views. Every request has exactly one
context object associated with it. This context is built up throughout the life
cycle of a request.

If you have never encountered the context pattern before, you should read
[the explanatory blog post](http://barunsingh.com/2018/03/04/context_pattern.html)
to get a thorough understanding of the motivations behind and benefits of this
code pattern, examples of before and after code, and a thorough explanation of
how everything works.

This README is intended to provide a reference for those who are already
somewhat familiar with the context pattern.

## Setting up the gem

To use this gem, you need to do two things:

1. Require it in your Gemfile:
   ```ruby
   gem 'context-pattern'
   ```

2. Add the following two lines to your `ApplicationController`:
   ```ruby
   include Context::Controller
   helper Context::BaseContextHelper
   ```

## Simple example

The example below is a simple one that is used to demonstrate various facets
of how this gem and the context pattern work. Suppose we have an online
bookstore and are looking at a `BooksController#show` action. We want to
retrieve the logged in user from the session and the book being viewed from the
params. We use a decorator to provide some functionality around showing the
user's name (this is contrived, but demonstrative).

```ruby
class ApplicationController < ActionController::Base
  include Context::Controller
  helper Context::BaseContextHelper

  before_action :set_application_context

  def set_application_context
    extend_context :Application, params: params, session: session
  end
end

class BooksController < ApplicationController
  def show
    extend_context :BookShow
  end
end

class ApplicationContext < Context::BaseContext
  view_helpers :current_user

  attr_accessor :session, :params

  def current_user
    User.find_by(id: session[:user_id])
  end
  memoize :current_user
end

class BookShowContext < Context::BaseContext
  view_helpers :book

  decorate :current_user, decorator: UserPresenter, memoize: true

  def book
    Book.find(params[:id])
  end
  memoize :book
end

class UserPresenter < SimpleDelegator
  def abbreviated_name
    "#{first_name} #{last_name[0]}"
  end
end
```

View file:
```erb
Hi, <%= current_user.abbreviated_name %>.
Here is information about <%= book.title %>
```

## Basic components of using the gem

* All context classes must inherit from `Context::BaseContext`
* To add a context to the context stack, use `extend_context`. Usage example:
  ```ruby
  extend_context :Foo, arg1: 1, arg2: 2
  # The above is equivalent to adding the following object to the context stack:
  #   FooContext.new(arg1: 1, arg2: 2)
  ```
* If you want to be able to provide arguments when initializing a context as
  in the example above, your context class needs to use `attr_accessor` to
  declare those attribute names.
* A context object has access to all public methods already defined in the
  context stack. It does not have access to any non-public methods used by
  other objects in the context stack.
* The order in which you add to the context stack is important. While a context
  object can reference public methods from earlier in the context stack, it can
  not make reference to public methods from objects added later to the context
  stack.
* Controllers have access to all public methods defined anywhere in the context
  stack.
* Views have access to all public methods in the context stack that are declared
  to be `view_helpers`.
* Methods do not necessarily need to be defined in the same context in which
  they are declarated to be `view_helpers`. But a method must be available to
  the context in which it is declared to be a view helper. This means the method
  must either be defined in that context or in a context that is already part
  of the context stack at the time.
* A context can not overwrite a public method that is already defined in the
  context stack. Trying to do so will cause a `Context::MethodOverrideError`
  exception to be raised.
* The `decorate` declaration provides a way to get around the above restriction
  in situations where we reasonably wish to decorate or present an object
  already available in the context stack. This declaration may be used as
  follows:
  ```ruby
  class BlahContext < Context::BaseContext
    # Suppose `foo` is a public method already available in the context stack
    decorate :foo, decorator: FooDecorator, args: [:bar, :baz], memoize: true

    # The above is functionaly equivalent to the code below:
    # def foo
    #   FooDecorator.new(@parent_context.foo, bar: bar, baz: baz)
    # end
    # memoize :foo

    def bar; end
    def baz; end
  end
  ```
* You can reference application routes in your context objects.
  `Context::BaseContext` includes `Rails.application.routes.url_helpers`. You
  can also use `link_to` within your contexts.


## Best practices for usage

The following suggestions are not requirements for using this gem, but bits of
advice that have been pulled together from using the context pattern across
the WegoWise codebase over a period of five years.

* You should have something like an `ApplicationContext` that takes params,
  session, etc. as arguments on initialization. The example in this README
  shows a simple version of this. If you do this, all later contexts will have
  access to the params, which will greatly simplify things.
* Aside from `ApplicationContext`, you should almost never need to provide any
  arguments to a context when initializing it via `extend_context`. This means
  those contexts shouldn't make use of `attr_accessor`. There may be some
  exceptions, but generally speaking a context should be able to figure out
  everything it needs from `params` and methods already available via the
  context stack.
* If you find yourself wanting to override methods from earlier contexts in
  ways that do not follow the decorator pattern, this is a sign you are not
  thinking about your code properly. Sometimes this may simply be a matter of
  having different method names for different concepts, Other times it may mean
  that your contexts are conceptually ambiguous.
* It is a best practice to add a comment at the top of each context file stating
  in plain language what the context is for the usage of that object. This
  should not need to be more than a couple short sentences. If you are having
  difficulty doing this, it may be a sign that you are trying to do too much
  within a single context object.
* `memoize` is made available via the `memoizer` gem, which is a dependency of
  this gem. It is a best practice to memoize all view helpers that do any sort
  of work, and to memoize objects that use the `decorate` declaration.


## How to test context objects

To be filled in soon.
