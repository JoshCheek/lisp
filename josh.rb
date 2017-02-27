require 'strscan'

class Lisp
  def self.eval(str)
    ast = parse str
    Lisp.new.eval(ast)
  end

  def self.parse(str)
    lex tokenize str
  end

  def self.tokenize(str)
    scanner = StringScanner.new(str)
    tokens  = []
    until scanner.eos?
      case
      when scanner.scan(/\d+/)
        tokens << scanner.matched.to_i
      when scanner.scan(/#t\b/)
        tokens << true
      when scanner.scan(/#f\b/)
        tokens << false
      else
        raise "Can't scan #{scanner.rest}"
      end
    end
    tokens
  end

  def self.lex(tokens)
    tokens
  end

  def eval(ast)
    ast.first
  end
end



require 'rspec/autorun'
RSpec.configure do |config|
  config.fail_fast = true
end
RSpec.describe 'Challenges' do
  def assert_eval(lisp, ruby)
    expect(Lisp.eval lisp).to eq ruby
  end

  describe 'Challenge 1' do
    it 'evaluates numbers' do
      assert_eval "1", 1
      assert_eval "2", 2
    end
    it 'evaluates booleans' do
      assert_eval "#t", true
      assert_eval "#f", false
    end
  end

  describe 'Challenge 2' do
    it 'evaluates simple addition' do
      assert_eval "(+ 1)", 1
      assert_eval "(+ 1 2)", 3
      assert_eval "(+ 1 2 10)", 13
    end
    it 'evaluates simple multiplicatione' do
      assert_eval "(* 2)", 2
      assert_eval "(* 2 2 3)", 12
    end
  end
end
