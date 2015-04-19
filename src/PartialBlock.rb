class PartialBlock
  attr_accessor :types, :block

  def initialize(tipos, &bloque) #tipos es un array de clases, &bloque es un bloque común y corriente (el do..end del ejemplo)
    if tipos.length != bloque.arity
      raise(ArgumentError, "La cantidad de parametros no concuerdan con los requeridos") #Tambien se le puede agregar una condicion, agrego link en el drive
      #throw new blah blah blah
      #¿cómo se tira *bien* una excepción en Ruby? | Confio en que este resuelto esto xD
    elsif
      self.types = tipos
      self.block = bloque
    end

  end

  def matches(*parametros)
    if self.types.length != parametros.length
      return false
    end

    i = 0
    for tipo in self.types
      unless parametros[i].class.ancestors.include?(tipo) #Las clases de los parametros heredan en algun momento de los tipos que espera el bloque
        return false
      end
      i += 1
    end
    return true
  end


  def call(*parameters)
    if !matches(*parameters)
      raise(ArgumentError, 'Se intentó llamar al bloque con argumentos no validos')
    end
    block.call(*parameters)
    end

end

#No encontre mejor lugar para definir esto por ahora

class ArgumentError < StandardError

end