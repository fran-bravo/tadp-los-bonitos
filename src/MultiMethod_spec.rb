require 'rspec'

describe 'multi methods' do

  it 'should todo ponerle nombre a este test' do

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

    #falta agregar los expects acá

    A.new.concat('hello', ' world') # devuelve 'helloworld'
    A.new.concat('hello', 3) # devuelve 'hellohellohello'
    A.new.concat(['hello', ' world', '!']) # devuelve 'hello world!'
    A.new.concat('hello', 'world', '!') # Lanza una excepción!


    #idem

    A.multimethods() #[:concat]
    A.multimethod(:concat) #Representación del multimethod


    true.should == false
  end
end