technology = Category.find_or_create_by!(name: "Tecnologia") do |category|
  category.description = "Productos electronicos y accesorios."
end

home = Category.find_or_create_by!(name: "Hogar") do |category|
  category.description = "Articulos para uso diario en casa."
end

Product.find_or_create_by!(name: "Teclado mecanico") do |product|
  product.description = "Teclado USB con switches mecanicos."
  product.price = 49.99
  product.stock = 15
  product.category = technology
end

Product.find_or_create_by!(name: "Mouse inalambrico") do |product|
  product.description = "Mouse ergonomico con conexion 2.4 GHz."
  product.price = 19.50
  product.stock = 30
  product.category = technology
end

Product.find_or_create_by!(name: "Termo acero") do |product|
  product.description = "Termo de 750 ml para bebidas frias o calientes."
  product.price = 12.75
  product.stock = 20
  product.category = home
end
