require 'minitest/spec'
require 'minitest/autorun'
require_relative '../lib/token_string.rb'

describe :TokenString do

  it 'should convert strings correctly' do

    test_strings = [
      [["Hello", "World"], {human: "Hello World", snake: "hello_world", camel: "HelloWorld", const: "HELLO_WORLD" }]
    ]
    test_strings.each do |string_pair|
      source = string_pair[0]
      strings = string_pair[1]
      strings.each_pair do |format, res|
        TokenString.convert_tokens_to( source, format).must_equal res
      end

    end
  end


  it 'should have a meaningful construct' do
    a = TokenString.from( :snake, 'hello_world_oh_my')
    a.format.must_equal :snake
    a.to_s.must_equal 'hello_world_oh_my'

    cc = a.camel
    cc.format.must_equal :camel
    cc.to_s.must_equal 'HelloWorldOhMy'

    hc = a.human
    hc.format.must_equal :human
    hc.to_s.must_equal 'Hello World Oh My'

    # The representation should not matter
    hc.must_equal a
  end


  it 'should be cloneable' do
    a = TokenString.from( :human, "Hello World")

    # create and modify a clone
    b = a.clone
    b.prefix "well"
    b.postfix( "and", "goodbye" )
    a.wont_equal b
    b.to_s.must_equal "Well Hello World And Goodbye"

    # but clones from the original should be equal
    c = a.clone
    a.must_equal c
  end


  it 'shoudl handle simple cases' do
    a = TokenString.from(:camel, "PropertyDb")
    a.snake.to_s.must_equal 'property_db'
  end


  it 'should properly handle prefixing and postfixing with other TokenStrings' do
    a = TokenString.from :camel, 'PropertyDb'

    b = TokenString.make :snake, 'mkz','monkeyplug'
    r = a.prefix!(b)
    r.format.must_equal :camel
    r.to_s.must_equal 'MkzMonkeyplugPropertyDb'

    c = TokenString.from :const, 'MESSAGE'
    r = r.postfix!(c)
    r.format.must_equal :camel
    r.to_s.must_equal 'MkzMonkeyplugPropertyDbMessage'

    prefix = TokenString.make( :const, 'MKZ', a )
    name =  TokenString.from( :const, 'HEADER' )

    c_name = name.derive!( prefix ).camel
    c_name.format.must_equal :camel
    c_name.to_s.must_equal "MkzPropertyDbHeader"

  end


  it 'should not throw errors on nils' do
    a = TokenString.make :snake, 'MKZ', 'Property', 'Db', 'Header', nil
    a.to_s.must_equal 'mkz_property_db_header'
  end

  it 'should return itself after force' do
    a = TokenString.make :snake, 'MKZ', 'Property', 'Db'
    a.force(:camel).must_equal a
  end
end
