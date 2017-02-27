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
    args = args.map { |arg| eval arg }
    if name == :+
      args.reduce(0, :+)
    elsif name == :*
      args.reduce(1, :*)
    elsif name == :if
      cond, true_case, false_case = args
      eval(cond) ? eval(true_case) : eval(false_case)
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
end

__END__


## Challenge 5

Evaluate top-level definitions:

```
lisp_eval("(def x 3)
           (+ x 1)").should == 4
```

## Challenge 6

Evaluate simple `let` bindings:

```
lisp_eval("(let (x 3)
             x)").should == 3
```

## Challenge 7

Evaluate more sophisticated `let` bindings:

```
lisp_eval("(let (x 3)
             (+ x 1))").should == 4
```

## Challenge 8

Evaluate `let` bindings with multiple variables:

```
lisp_eval("(let (x 3
                 y 4)
             (+ x y))").should == 7
```

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
