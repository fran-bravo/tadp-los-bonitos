class PartialBlock

  def initialize(tipos, &bloque) #tipos es un array de clases, &bloque es un bloque común y corriente (el do..end del ejemplo)
    if tipos.length != bloque.arity
      raise()
      #throw new blah blah blah
      #¿cómo se tira *bien* una excepción en Ruby?
    end
  end


end