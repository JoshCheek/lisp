class Lisp
  def self.eval(str)
    parse str
  end

  def self.parse(str)
    case str
    when /\A\d+\z/
      str.to_i
    when '#t'
      true
    when '#f'
      false
    else
      raise "can't parse: #{str.inspect}"
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

  it 'evaluates numbers' do
    assert_eval "1", 1
    assert_eval "2", 2
  end
  it 'evaluates booleans' do
    assert_eval "#t", true
    assert_eval "#f", false
  end
end
