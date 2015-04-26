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

  def comprobar_ancestros(tuplas_tipos) #Recibe arrays de arrays [[tipo_param, tipo_del_bloqu], ... ]
    tuplas_tipos.all? { |tupla| tupla[0].ancestors.include?(tupla[1]) } #Valida que el bloque sea un ancestro del param
  end

  def validar_tipos_parametros(*parametros)
    tipos = parametros.map { |param| param.class } #Transforma el array de parametros a un array de sus Clases
    tipos = tipos.zip(self.types) #Agrupa uno a uno los arrays y forma un array de arrays

    comprobar_ancestros(tipos)

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


