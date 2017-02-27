require 'strscan'

class Lisp
  def self.eval(str)
    ast = parse str
    Lisp.new.eval(parse str)
  end

  def self.parse(str)
    scanner = StringScanner.new(str)
    bodies = []
    bodies << scan_for_ast(scanner) until scanner.eos?
    [:program, bodies]
  end

  def self.scan_for_ast(scanner)
    scanner.scan(/\s+/)
    case
    when scanner.eos?
      # does this actually happe?
      [:bool, nil]
    when scanner.scan(/#t\b/)
      [:bool, true]
    when scanner.scan(/#f\b/)
      [:bool, false]
    when scanner.scan(/\d+/)
      [:int, scanner.matched.to_i]
    when scanner.scan(/\(/)
      list = []
      loop do
        scanner.scan(/[\s\n]+/) # whitespace
        break if scanner.scan(/\)/)
        list << scan_for_ast(scanner)
      end
      [:list, list]
    when scanner.scan(/[^ )]+/)
      [:sym, scanner.matched.intern]
    else
      raise "Can't scan #{scanner.rest}"
    end
  end

  def initialize
    @defs = {
      :+  => [:fn, -> lst {
        lst.map { |a| eval a }.reduce(0, :+)
      }],
      :*  => [:fn, -> lst {
        lst.map { |a| eval a }.reduce(1, :*)
      }],
      :if => [:fn, -> lst {
        cond, true_case, false_case = lst
        eval(cond) ? eval(true_case) : eval(false_case)
      }],
      :def => [:fn, -> lst {
        (name_type, name), body = lst
        if name_type == :sym
          @defs[name] = body
        else
          require "pry"
          binding.pry
        end
      }],
      :let => [:fn, -> lst {
        let_asts, body = lst
        _list, lets = let_asts
        lets.each_cons(2) do |(_sym, name), val_ast|
          # FIXME: should be in a separate scope, should go away after evaluating the body
          @defs[name] = val_ast
        end
        eval body
      }]
    }
  end

  def eval(ast)
    type, val = ast
    case type
    when :program
      val.reduce(nil) { |_, child| eval child }
    when :bool, :int
      val
    when :sym
      unless @defs.key? val
        require "pry"
        binding.pry
      end
      eval @defs.fetch(val)
    when :list
      first, *rest = val
      eval(first).call(rest)
    when :fn
      val
    else
      require "pry"
      binding.pry
    end
  end

  # def quote(ast)
  #   type, val = ast
  #   case type
  #   when :program
  #     require "pry"
  #     binding.pry
  #   when :bool, :int, :sym
  #     val
  #   when :list
  #     val.map { |e| quote e }
  #   when :fn
  #     require "pry"
  #     binding.pry
  #   else
  #     require "pry"
  #     binding.pry
  #   end
  # end
end



require 'rspec/autorun'
RSpec.configure do |config|
  config.formatter = 'documentation'
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

  describe 'Challenge 3' do
    it 'evaluates nested addition and multiplication calls' do
      assert_eval "(+ 1 (* 2 3))", 7
    end
  end

  describe 'Challenge 4' do
    it 'evaluates conditionals' do
      assert_eval "(if #t 1 2)", 1
      assert_eval "(if #f 1 2)", 2
      assert_eval "(if #f #t #f)", false
    end
  end

  describe 'Challenge 5' do
    it 'evaluates top-level definitions' do
      assert_eval "(def x 3)
                   (+ x 1)", 4
    end
  end

  describe 'Challenge 6' do
    it 'evaluates simple `let` bindings' do
      assert_eval "(let (x 3)
                     x)", 3
    end
  end

  describe 'Challenge 7' do
    it 'evaluates more sophisticated `let` bindings' do
      assert_eval "(let (x 3)
                     (+ x 1))", 4
    end
  end

  describe 'Challenge 8' do
    it 'evaluates `let` bindings with multiple variables' do
      assert_eval "(let (x 3
                      y 4)
                     (+ x y))", 7
    end
  end
end


__END__
## Challenge 9

Evaluate function definitions:

```
code = "(defn add2 (x)
          (+ x 2))

        (add2 9)"

lisp_eval(code).should == 1
```

## CHALLENGE 10
Evaluates function definitions with multiple variables:

```
code = "(defn maybeAdd2 (bool x)
          (if bool
            (+ x 2)
            x))

        (+ (maybeAdd2 1 #t) (maybeAdd2 1 #f))"

lisp_eval(code).should == 4
```
