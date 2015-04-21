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

  def validar_cantidad_parametros(*parametros)
    self.types.length == parametros.length
  end

  def validar_tipos_parametros(*parametros)
    i = 0

    for tipo in self.types
      unless parametros[i].class.ancestors.include?(tipo) #Las clases de los parametros heredan en algun momento de los tipos que espera el bloque
        return false
      end
      i += 1
    end
    return true

  end

  def matches(*parametros)
    validar_cantidad_parametros(*parametros) && validar_tipos_parametros(*parametros)
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


class Multimethod
  attr_accessor :simbolo, :bloques_parciales

  def initialize(method)
    self.simbolo = method
    self.bloques_parciales = []
  end

  def agregar_bloque(partial_block)
    posicion = self.bloques_parciales.any? do |bloque_parcial| bloque_parcial.types.eql?(partial_block.types) end

    unless posicion == nil
      bloques_parciales.delete_at(posicion)
    end

    bloques_parciales << partial_block

  end

end


class Module
  attr_accessor :multimetodos #Lista con los multimethods definidos

  def multimetodos
    @multimetodos= @multimetodos || []
  end

  def multimethods
    self.multimetodos.map {|multimetodo| multimetodo.simbolo}
  end

  def partial_def(simbolo, tipos, &bloque)

    bloque_parcial = PartialBlock.new(tipos) &bloque

    if self.multimethods.include?(simbolo)
      self.agregar_multimethod_existente(simbolo, bloque_parcial)
    else
      agregar_nuevo_multimetodo(simbolo, bloque_parcial)
    end

  end

  def agregar_nuevo_multimetodo(simbolo, bloque_parcial)
    nuevo_multimetodo = Multimethod.new(simbolo)
    nuevo_multimetodo.agregar_bloque(bloque_parcial)
    multimetodos << nuevo_multimetodo
  end

  def agregar_multimethod_existente(simbolo, bloque_parcial)
    encontrado = multimetodos.find_index do |multimethod| multimethod.simbolo == simbolo end
    encontrado.agregar_bloque_si_falta(bloque_parcial)
  end

  def responds_to?(simbolo)

    multimethods.include?(simbolo) || super

  end
end