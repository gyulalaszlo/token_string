token_string
============

Provides a way to deal with CamelCase, snake_case and more in a more elegant way then ActiveSupport::Inflector.


examples of usage:
```ruby

irb(main):001:0> require 'token_string'
=> true

# Use TokenString.from <format>, <string> to create a tokenized version
# of a string.

irb(main):002:0>  a = TokenString.from :camel, 'PropertyDb'
=> #<TokenString::Impl:0x007fce5383a7b0 @format=:camel, @tokens=["Property", "Db"]>
irb(main):003:0>  b = TokenString.make :snake, 'mkz','monkeyplug'
=> #<TokenString::Impl:0x007fce5309ef38 @format=:snake, @tokens=["mkz", "monkeyplug"]>

# Add a prefix to the string. The ! on the end indicates that this
# version of prefix will clone the array of tokens then alters and returns the clone.

irb(main):004:0>  r = a.prefix!(b)
=> #<TokenString::Impl:0x007fce5308f240 @format=:camel, @tokens=["mkz", "monkeyplug", "Property", "Db"]>

# The format of the clone stays the same
irb(main):005:0> r.format
=> :camel

# We can access the formatted version using to_s

irb(main):006:0> r.to_s
=> "MkzMonkeyplugPropertyDb"

# derive(<prefix>, <postfixes>...) creates a clone and adds <prefix> to
# the beginning and <postifixes to the end.

irb(main):007:0> r.derive("make", "object", "controller")
=> #<TokenString::Impl:0x007fce53064838 @format=:camel, @tokens=["make", "mkz", "monkeyplug", "Property", "Db", "object", "controller"]>

# Calling #snake #human #const or #camel on the object returns a copy of
# the object with the new format.
#
# WARNING: adding prefixes and postfixes without cloning the objct first
# modifies the existing token list in that object.

irb(main):008:0> r.snake
# => #<TokenString::Impl:0x007fce53055180 @format=:snake, @tokens=["mkz", "monkeyplug", "Property", "Db"]>
irb(main):009:0> t = r.derive("make", "object", "controller")
# => #<TokenString::Impl:0x007fce53036a00 @format=:camel, @tokens=["make", "mkz", "monkeyplug", "Property", "Db", "object", "controller"]>
irb(main):010:0> t.format
# => :camel
irb(main):011:0> ts = t.snake
# => #<TokenString::Impl:0x007fce530258e0 @format=:snake, @tokens=["make", "mkz", "monkeyplug", "Property", "Db", "object", "controller"]>
irb(main):013:0> ts.to_s
# => "make_mkz_monkeyplug_property_db_object_controller"
irb(main):014:0> r.to_s
# => "MkzMonkeyplugPropertyDb"
irb(main):015:0> r.force(:snake)
# => #<TokenString::Impl:0x007fce5308f240 @format=:snake, @tokens=["mkz", "monkeyplug", "Property", "Db"]>
irb(main):016:0> r.to_s
# => "mkz_monkeyplug_property_db"
irb(main):017:0> v = r.const
# => #<TokenString::Impl:0x007fce53aeb518 @format=:const, @tokens=["mkz", "monkeyplug", "Property", "Db"]>
irb(main):018:0> v.to_s
# => "MKZ_MONKEYPLUG_PROPERTY_DB"
irb(main):019:0> r.to_s
# => "mkz_monkeyplug_property_db"
irb(main):020:0> v == r
# => true

```

Built-in formats
================

Currently the built in formats:
* :camel => CamelCase
* :snake => snake_case
* :human => Human Case
* :const => CONST_CASE


But declaring new formats is easy (look at the end of token_string.rb).

