require './spec_helper'
require './lisp'


describe '#lisp_eval' do
  describe "CHALLENGE 1" do
    it "lisp_evaluates numbers" do
      lisp_eval("1").should == 1
    end

    it "lisp_evaluates booleans" do
      lisp_eval("#t").should == true
    end
  end

  describe "CHALLENGE 2" do
    it "lisp_evaluates addition" do
      lisp_eval("(+ 1 2)").should == 3
    end

    it "lisp_evaluates multiplication" do
      lisp_eval("(* 2 2 3)").should == 12
    end
  end

  describe "CHALLENGE 3" do
    it "lisp_evaluates nested arithmetic" do
      lisp_eval("(+ 1 (* 2 3))").should == 7
    end
  end

  describe "CHALLENGE 4"  do
    it "lisp_evaluates conditionals" do
      lisp_eval("(if #t 1 2)").should == 1
      lisp_eval("(if #f #t #f)").should == false
    end
  end

  describe "CHALLENGE 5"  do
    it "lisp_evaluates top-level defs" do
      lisp_eval("(def x 3)
                 (+ x 1)").should == 4
    end
  end

  describe "CHALLENGE 6"  do
    it "lisp_evaluates simple `let` bindings" do
      lisp_eval("(let (x 3)
                   x)").should == 3
    end
  end

  describe "CHALLENGE 7"  do
    it "lisp_evaluates let bindings with a more sophisticated body" do
      lisp_eval("(let (x 3)
                   (+ x 1))").should == 4
    end
  end

  describe "CHALLENGE 8"  do
    it "lisp_evaluates let bindings with multiple variables" do
      lisp_eval("(let (x 3
                       y 4)
                   (+ x y))").should == 7
    end
  end

  describe "CHALLENGE 9"  do
    it "lisp_evaluates function definitions with single variables" do
      code = "(defn add2 (x)
                (+ x 2))

              (add2 10)"

      lisp_eval(code).should == 12
    end
  end

  describe "CHALLENGE 10"  do
    it "lisp_evaluates function definitions with multiple variables" do
      code = "(defn maybeAdd2 (bool x)
                (if bool
                  (+ x 2)
                  x))

              (+ (maybeAdd2 #t 1) (maybeAdd2 #f 1))"

      lisp_eval(code).should == 4
    end
  end
end
