require 'strscan'

class Lisp
  def self.eval(str)
    Lisp.new.eval(parse str)
  end

  def self.parse(str)
    scan_for_ast StringScanner.new(str)
  end

  def self.scan_for_ast(scanner)
    case
    when scanner.eos?
      nil
    when scanner.scan(/\d+/)
      scanner.matched.to_i
    when scanner.scan(/#t\b/)
      true
    when scanner.scan(/#f\b/)
      false
    when scanner.scan(/\(/)
      list = []
      loop do
        scanner.scan(/\s+/) # whitespace
        break if scanner.scan(/\)/)
        list << scan_for_ast(scanner)
      end
      list
    when scanner.scan(/\S+/)
      scanner.matched.intern
    else
      require "pry"
      binding.pry
      raise "Can't scan #{scanner.rest}"
    end
  end

  def eval(ast)
    if ast.kind_of? Array
      eval_list ast
    else
      ast
    end
  end

  private

  def eval_list(list)
    name, *args = list
    if name == :+
      args.reduce(0, :+)
    elsif name == :*
      args.reduce(1, :*)
    else
      require "pry"
      binding.pry
    end
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
    it 'evaluates simple addition', t:true do
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
