################################### Clase Universal ###########################

class Animal
  attr_accessor :energia, :vida

  def perder_energia(energy)
    self.energia -= energy
  end

  def ganar_energia(energy)
    self.energia += energy
  end

end

################################### Modulos del Mixin ############################
module Ave

  def volar(unos_kms)
    self.perder_energia(10 * unos_kms)
  end

  def comer(unos_gramos)
    self.ganar_energia(2 * unos_gramos)
  end

end

module Hombre

  def comer(unos_gramos)
    self.ganar_energia(6 * unos_gramos)
  end

end

############################# Lo que genero le dio la vida a esto #############

class Paloma < Animal
  include Ave

  def vitalidad()
    return self.energia + self.vida
  end

  def bailar_zumba()
    self.perder_energia(15)
  end

end

###################### Clases que aplican el Mixin #######################

class Birdman < Animal
  include Ave
  include Hombre

end

class Manbird < Animal
  include Hombre
  include Ave

end

####################### Agrego un nivel mas ############################

class Murcielago < Animal
  include Ave

end

class Batman < Murcielago
  include Hombre

end