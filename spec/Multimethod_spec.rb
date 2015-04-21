require 'rspec'
require_relative '../src/PartialBlock'
require_relative '../src/Multimethod'

describe 'Tests sobre multimethods' do

  before (:all) do
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

    end
  end

  it 'Se definió un multimétodo' do
    expect(A.multimetodos.length).to eq(1)
  end

  it 'Se definió un multimétodo con 3 definiciones parciales' do
    expect(A.multimetodos[0].bloques_parciales.length).to eq(3)
  end

  it 'Se redefine un multimétodo, que sobreescribe otro con los mismos tipos' do
    class A
      partial_def :concat, [String, Integer] do |s1, n| "Hola Maiu!" end
    end

    expect(A.multimetodos.first.bloques_parciales.last.call("Juli", 9)).to eq("Hola Maiu!")
    expect(A.multimetodos.first.bloques_parciales.length).to eq(3)
  end

  it 'funciona el responds_to? para partial_def' do
    
    expect(A.new.respond_to?(:concat)).to eq(true)

  end
end