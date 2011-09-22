StupidLittleTemplate is a really dumb templating "system" currently clocking in
around 20 lines. It has no dependencies.

Usage
-----
```ruby
require 'stupid_little_template'
include StupidLittleTemplate

# sltmpl takes a template string and "compiles" it into a Proc. The second
# parameter must be a Binding object.
tmpl = sltmpl 'I like to eat :food in :city.', binding

food = 'pizza'
city = 'Chicago'

# Call yield on the Proc and the resulting text is returned.
tmpl.yield  # => I like to eat pizza in Chicago.

# Change variables in the local scope...
food = 'spaghetti'
city = 'Rome'

# ...and call yield again and the new values come out in the text.
tmpl.yield  # => I like to eat spaghetti in Rome.
```

Yep, it plucks variables right out of the local scope. You can do it with all
kinds of variables:

```ruby
Constant    = 'My'
$global_var = 'name'

class Klass
  include StupidLittleTemplate

  @instance_var = 'is'
  @@class_var   = 'StupidLittleTemplate'

  def foo
    sltmpl ':Constant :$global_var :@instance_var :@@class_var', binding
  end
end

k = Klass.new

k.foo.yield # => My name is StupidLittleTemplate
```

Hilariously reckless!

You can do some interesting(ish) things with [`binding`][1], though:

```ruby
class Klass
  def initialize name, age
    @name = name
    @age  = age
  end

  def my_binding
    binding
  end
end

k = Klass.new 'Alice', 29

sltmpl("My name is :@name and I'm :@age years old.", k.my_binding).yield
# => My name is Alice and I'm 29 years old.
```

[1]: http://www.ruby-doc.org/core/classes/Kernel.html#M001448

FAQ
---

* **Q: Can you do anything neat with logic in the templates?**

    **A:** Nope.


* **Q: Is this just a stupid toy?**

    **A:** Yep.

* **Q: What happens if I do this:**

    ```ruby
    stupid = sltmpl ':fooquux:bar', binding

    foo = 'FOO'; bar = 'BAR'

    stupid.yield
    ```

    **A:** You get `:fooquuxBAR`. There's a [failing test] for this.

[failing test]: https://github.com/jrunning/StupidLittleTemplate/blob/master/test/template_test.rb#L64-76


* **Q: Can I pass in a `Hash` of values instead of exposing all the locals?**

    **A:** If it could do that I might not have named it StupidLittleTemplate.
      If you really want, though:

      ```ruby
      class Hash
        def my_binding; binding; end
      
        def method_missing meth, *args
          self[meth] || super
        end
      
        def respond_to? meth; self[meth] || super; end
      end
      
      params = { food: 'cheese', city: 'Milwaukee' }
      
      sltmpl 'I eat :food in :city.', params.my_binding
      # => I eat cheese in Milwaukee.
      ```

      But that's just ridiculous.

Credits
-------
The [regular expression] for extracting teplate variables is adapted from [this
StackOverflow answer][SO] by [rjk].

[regular expression]: https://github.com/jrunning/StupidLittleTemplate/blob/master/lib/stupid_little_template.rb#L2
[SO]:   http://stackoverflow.com/questions/3648551/regex-that-matches-valid-ruby-local-variable-names/3648591#3648591
[rjk]:  http://stackoverflow.com/users/434038/rjk
