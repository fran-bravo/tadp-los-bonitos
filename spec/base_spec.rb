require 'rspec'
require_relative '../src/Multimethod'
require_relative '../src/PartialBlock'

describe 'Pruebas sobre base' do

  class A
    partial_def :m, [Object] do |o|
      "A>m"
    end
  end

  class B < A

    partial_def :m, [Integer] do |i|
      base.m([Numeric], i) + " => B>m_integer(#{i})"
    end

    partial_def :m, [Numeric] do |n|
      base.m([Object], n) + " => B>m_numeric"
    end

  end


  it 'test del enunciado' do
    expect(B.new.m(1)).to eq("A>m => B>m_numeric => B>m_integer(1)")
  end
end