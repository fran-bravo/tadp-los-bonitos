class PartialBlock
  attr_accessor :types, :block

  def initialize(tipos, &bloque)
    if tipos.length != bloque.arity
      raise(ArgumentError, "La cantidad de parametros no concuerdan con los requeridos")
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
      unless parametros[i].class.ancestors.include?(tipo)
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


class ArgumentError < StandardError

end


