require 'rspec'
require_relative '../src/Multimethod'
require_relative '../src/PartialBlock'
require_relative '../spec/tanques_fixture'

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

  class A

    partial_def :concat, [String, String] do |s1, s2|
      s1 + s2
    end


    partial_def :concat, [String, Integer] do |s1,n|
      s1 * n
    end

    partial_def :concat, [Array] do |a|
      a.join
    end

    partial_def :concat, [Object, Object] do |o1, o2|
      "Objetos concatenados"
    end
  end

  class B
    partial_def :concat, [String, String] do |o1, o2|
      base.concat([Object, Object], o1, o2)
    end

    partial_def :concat, [Integer] do |a|
      base.concat([Array, Integer, String], [a], a, "a")
    end
  end


  it 'test del enunciado' do
    expect(B.new.m(1)).to eq("A>m => B>m_numeric => B>m_integer(1)")
  end

  it 'base recibe más de 1 parámetro' do
    expect(B.new.concat("hola", "Juli")).to eq("Objetos concatenados")
  end

  it 'no está definido el método que busca base' do
    expect{B.new.concat(2)}.to raise_error(BaseError)
  end

  it 'base en un multimétodo definido en un objeto' do
    b = B.new
    b.partial_def(:concat, [Array, String]) do |a, s|
      base.concat([Array], a)
    end

    expect(b.concat(["J", "u", "l", "i"], "Hola")).to eq("Juli")
  end

end