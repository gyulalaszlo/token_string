class TokenString

  class Format

    # Convert an input string in this format to a token list and validate it
    def convert_from str
      t = tokenize( str ).reject {|tok| tok == nil || tok.empty?}
      unless t.all?{|tok| validate(tok)}
        raise ArgumentError.new("Bad token in input: #{str.inspect} (tokens: #{t.inspect})")
      end
      t
    end

    # Converts the tokens to this format.
    def convert_to tokens
      join( tokens.map{|t| process(t.to_s) })
    end

    # Validate each token. For now its just to check if they are an identifier.
    def validate token
      token =~ /[A-Za-z0-9]/
    end
  end


  # Register a Format.
  #
  # Registering a format adds that format to the available formats and
  # creates two accessors on Impl instances: the name of the #<format>
  # which creates a copy of the Impl with the requested format,
  # and #<format>! which clones then sets the format.
  def self.add name, format
    @converters = {} unless @converters
    @converters[name] = format
    # Register a converter for Impl
    Impl.class_eval([
      "def #{name}; Impl.new(:#{name}, @tokens); end",
      "def #{name}!; clone.force(:#{name}); end",
    ].join("\n") )
  end

  # Helper to convert a list of tokens to a specific format
  def self.convert_tokens_to( stream, format )
    c_to = @converters[format]
    return str unless c_to
    c_to.convert_to( stream )
  end

  # Gets a list of all the known formats.
  def self.known_formats
    @converters.keys
  end

  # Creates a new TokenString from the given string using the
  # supplied format.
  #
  # If no such format is registered, the method throws
  # an NoSuchConverterError.
  #
  # If the converter finds the string invalid, it throws
  # an ArgumentError.
  def self.from( format, string )
    converter = @converters[format]
    unless converter
      raise NoSuchConverterError.new(
        "Unknown format for input: #{format.inspect}." +
        "Available formats: #{@converters.keys.inspect}")
    end
    Impl.new( format, converter.convert_from( string ) )
  end


  # Construct a new TokenString from the format and tokens.
  def self.make( format, *tokens )
    Impl.new( format, linearize_tokens(tokens.flatten) )
  end


  # The value type that implements the whole shebang.
  class Impl
    attr_reader :format, :tokens

    #:nodoc:
    def initialize( format, tokens)
      # this should be called only from TokenString.from & TokenString.make
      @format, @tokens = format, tokens
    end

    # "cast" this Imple to a different type.
    # These casts use the same underlying buffer to be cheap.
    def to(new_format)
      Impl.new( new_format, tokens )
    end


    # Make this Impl a different type.
    #
    # This method simply sets format to the given new
    # format.
    def force(new_format)
      @format = new_format
      self
    end

    # Convert to string
    def to_s
      TokenString.convert_tokens_to( @tokens, @format )
    end

    # Two such strings should be equal independent of the representation
    def ==(other)
      return false unless other
      other.tokens == tokens
    end

    # Clones
    def clone
      Impl.new( format, tokens.map{|t|t})
    end

    # Editing the contents of the string
    # ----------------------------------

    # Appends a token to the beginning to the tokens
    def prefix( *pf )
      tokens.unshift(*TokenString.linearize_tokens(pf))
      self
    end

    # Equal to calling .clone.prefix(...)
    def prefix!( *pf )
      clone.prefix(*pf)
    end

    # Appends a token to the end of the tokens
    def postfix( *pf )
      tokens.push(*TokenString.linearize_tokens(pf))
      self
    end

    # Equal to calling .clone.postfix(...)
    def postfix!( *pf )
      clone.postfix(*pf)
    end

    # Equal to calling prefix(<prefix>).postfix(<postfix>)
    def surround( prefix_, *postfix_ )
      prefix( prefix_ )
      postfix( *postfix_ ) unless postfix_.empty?
      self
    end

    # Equal to calling clone.surround()
    def derive!(*args)
      clone.surround( *args)
    end

    alias :derive :derive!


    # Some string methods that may get called on us
    def lines; [to_s]; end

  end

  class NoSuchConverterError < ArgumentError
    def initialize msg, *args
      super(msg, *args)
    end
  end

  private
  #
  # :nodoc
  def self.linearize_tokens toks
    o = []
    return o unless toks
    toks.each do |tok|
      case
      when !tok then # nothing...
      when tok.is_a?(Impl) then o.push(*linearize_tokens(tok.tokens))
      else o << tok
      end
    end
    o
  end
end

class HumanFormat < TokenString::Format
  def tokenize(str);          str.split( /\s+/);  end
  def process(token);   token.capitalize;  end
  def join(tokens);    tokens.join(' ');   end
end

class SnakeCase < TokenString::Format
  def tokenize(str);          str.split( /_+/);  end
  def process(token);   token.downcase;  end
  def join(tokens);    tokens.join('_');   end
end

class CamelCase < TokenString::Format
  def tokenize(str);    str.gsub( /[A-Z]+/, '_\0' ).split(/_+/);  end
  def process(token);   token.capitalize;  end
  def join(tokens);    tokens.join('');   end
end

class ConstCase < TokenString::Format
  def tokenize(str);    str.split(/_+/);  end
  def process(token);   token.upcase;  end
  def join(tokens);     tokens.join('_');   end
end

TokenString.add :human, HumanFormat.new
TokenString.add :const, ConstCase.new
TokenString.add :camel, CamelCase.new
TokenString.add :snake, SnakeCase.new
