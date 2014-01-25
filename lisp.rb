def make_kernel_fn_table
  {
    "+" => lambda { |*args| args.reduce(:+) },
    "*" => lambda { |*args| args.reduce(:*) },
    "if" => lambda { |cond, true_case, false_case| if cond; true_case; else; false_case; end },
    "def" => lambda { |name, value| @@user_vars[name] = value }
  }
end

def make_kernel_macro_table
  {
    "let" => lambda do |*body|
      original_user_vars = @@user_vars
      begin
        closing_bindings_index = index_closing_s_expr(body)
        var = nil
        body[1..closing_bindings_index-1].each do |token|
          if var.nil?
            var = token
          else
            @@user_vars[var] = eval_token(token)
            var = nil
          end
        end
        evaluate(body[closing_bindings_index..body.length]).last
      ensure
        @@user_vars = original_user_vars
      end
    end,
    "defn" => lambda do |name, *body|
      closing_vars_index = index_closing_s_expr(body)
      vars = body[1..closing_vars_index-1]
      @@macro_table[name] = lambda do |*args|
        if args.length != vars.length
          raise ArgumentError.new("wrong number of arguments (#{args.length} for #{args_length})")
        end
        bindings = vars.zip(args).flatten.unshift("(")
        @@macro_table["let"].call(*(bindings + body[closing_vars_index..body.length-1]))
      end
    end
  }
end

def lisp_eval(expression)
  @@fn_table = make_kernel_fn_table
  @@macro_table = make_kernel_macro_table
  @@user_vars = {}
  tokens = scan_tokens(expression)
  evaluate(tokens).last
end

def scan_tokens(expression)
  split_expr = expression.split(" ")
  split_expr.reduce([]) do |acc, chunk|
    acc += define_tokens(chunk)
  end
end

def define_tokens(chunk)
  tokens = []
  if is_open_s_expr?(chunk)
    tokens << "("
    tokens += define_tokens(chunk[1..-1])
  elsif is_closed_s_expr?(chunk)
    tokens += define_tokens(chunk[0..chunk.length-2])
    tokens << ")"
  else
    tokens << chunk
  end
  tokens
end

def evaluate(tokens, completed = [])
  return completed if tokens.empty?
  if tokens.first == "("
    i = index_closing_s_expr(tokens)
    args = tokens[2..i-1]
    completed << apply(tokens[1], args)
    completed = evaluate(tokens[i+1..-1], completed)
  else
    completed << eval_token(tokens.first)
    completed = evaluate(tokens[1..-1], completed)
  end
  completed
end

def index_closing_s_expr(tokens)
  closing_to_find = 0
  tokens.each_with_index do |token, index|
    if token == "("
      closing_to_find = closing_to_find + 1
    elsif token == ")"
      if closing_to_find == 1
        return index
      else
        closing_to_find = closing_to_find - 1
      end
    end
  end
end

def apply(fn, args)
  if @@fn_table.include?(fn)
    eval_args = evaluate(args)
    @@fn_table[fn].call(*eval_args)
  elsif @@macro_table.include?(fn)
    @@macro_table[fn].call(*args)
  else
    raise "#{fn} is not a function"
  end
end

def eval_token(token)
  if is_integer?(token)
    token.to_i
  elsif is_bool?(token)
    token == "#t"
  elsif @@user_vars.include?(token)
    @@user_vars[token]
  else
    token
  end
end

def is_integer?(token)
  token =~ /^[-+]?[0-9]+$/
end

def is_bool?(token)
  token =~ /^#[t||f]$/
end

def is_open_s_expr?(token)
  token =~ /^\(.*$/
end

def is_closed_s_expr?(token)
  token =~ /^.*\)$/
end
