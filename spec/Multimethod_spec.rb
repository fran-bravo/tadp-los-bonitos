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

      partial_def :concat, [Object, Object] do |o1, o2|
        "Objetos concatenados"
      end

    end
  end

  it 'Se definió un multimétodo' do
    expect(A.multimetodos.length).to eq(1)
  end

  it 'Se definió un multimétodo con 4 definiciones parciales' do
    expect(A.multimetodos[0].bloques_parciales.length).to eq(4)
  end

  it 'Se redefine un multimétodo, que sobreescribe otro con los mismos tipos' do
    class A
      partial_def :concat, [String, Integer] do |s1, n| "Hola Maiu!" end
    end

    expect(A.multimetodos.first.bloques_parciales.last.call("Juli", 9)).to eq("Hola Maiu!")
    expect(A.multimetodos.first.bloques_parciales.length).to eq(4)
  end

  it 'Se puede preguntar por los multimétodos definidos en la clase' do
    expect(A.multimethods).to eq([:concat])
  end

  it 'funciona el responds_to? para partial_def' do

    expect(A.new.respond_to?(:concat)).to eq(true)

  end

  it 'funciona el responds_to? para un método común, en una clase que definió un partial method' do
    expect(A.new.respond_to?(:to_s)).to eq(true)
    # true, define el método normalmente
  end

  it 'funciona el responds_to? para un multimethod preguntando por una firma exactamente como una de las que tiene' do
    expect(A.new.respond_to?(:concat, false, [String,String])).to eq(true)
    # true, los tipos coinciden
  end

  it 'funciona el responds_to? para un multimethod preguntando por una firma que matchea por herencia con una de las que tiene' do
    expect(A.new.respond_to?(:concat, false, [Integer,A])).to eq(true)
    #esto matchea con el partial def que toma [Object, Object]
  end

  it 'puedo preguntar responds_to? por algo que es un método y no un multimétodo, y si especifico la firma no matchea' do
   expect(A.new.respond_to?(:to_s, false, [String])).to eq(false)
    # false, no es un multimethod
  end

  it 'puedo preguntar responds_to? por un multimethod que existe pero con una firma que no tiene, y da false' do
   expect(A.new.respond_to?(:concat, false, [String,String,String])).to eq(false) # false, los tipos no coinciden
  end



  it 'La distancia del parámetro se calcula correctamente' do
    expect(Multimethod.new(:metodo).distancia_parametro(Numeric, 3)).to eq(2)
  end

  it 'Se calcula correctamente la distancia de los parámetros' do
    multimetodo = Multimethod.new(:metodo)
    expect(multimetodo.distancia_parametros([Numeric, Numeric], [3, 3.0])).to eq(4)
  end

  it 'Se invoca un multimetodo' do
    expect(A.new.concat('hello', 3)). to eq("hellohellohello")
  end


end