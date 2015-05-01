require_relative '../src/Multimethod'
require_relative '../src/PartialBlock'

class Soldado
  attr_accessor :nombre

  def initialize(n="")
    #esto lo tengo que agregar porque a veces los test del enunciado llaman al constructor sin nada, y a veces con un nombre
    self.nombre= n
  end
# ... implementación de soldado
end

class Tanque
  # ... implementación de tanque

  def ataca_con_canion(objetivo)
    return "boom"
  end

  def ataca_con_ametralladora(objetivo)
    return "ratatatatatata"
  end

  def atacar_con_satelite(objetivo)
    return "niuuuuuuuum"
  end

  def pisar(objetivo)
    return "splat"
  end

  partial_def :ataca_a, [Tanque] do |objetivo|
    self.ataca_con_canion(objetivo)
  end

  partial_def :ataca_a, [Soldado] do |objetivo|
    self.ataca_con_ametralladora(objetivo)
  end
end

class Avion
  #... implementación de avión
end

#abro la clase tanque
class Tanque
  #Agrego una implementación para atacar aviones que NO pisa las anteriores
  partial_def :ataca_a, [Avion] do |avion|
    self.atacar_con_satelite(avion)
  end

  #Cambio la definición previa de cómo atacar a un soldado
  partial_def :ataca_a, [Soldado] do |soldado|
    self.pisar(soldado)
  end
end