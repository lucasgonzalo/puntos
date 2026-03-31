# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
# AdminUser.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password') if Rails.env.development?


require 'net/http'
source = 'https://infra.datos.gob.ar/catalog/modernizacion/dataset/7/distribution/7.5/download/localidades.json'
resp = Net::HTTP.get_response(URI.parse(source))
data = resp.body
result = JSON.parse(data)

country = Country.find_by(name: 'Argentina')
country ||= Country.create!(name: 'Argentina')

result['localidades'].each do |city|
  state_name = city['provincia']['nombre']
  state = State.find_by(country: country, name: state_name)
  state ||= State.create!(country: country, name: state_name)

  city_name = city['localidad_censal']['nombre']
  city = City.find_by(state: state, name: city_name)
  City.create!(state: state, name: city_name) unless city
end

#---------------------------------------------------------------------------------------------------------------------
#------------------------------Creamos Relaciones de parentezco de personas-------------------------------------------
relationships = ['Pareja', 'Madre', 'Padre', 'Hijo/a', 'Hermano/a', 'Otro']
relationships.each do |relationship_name|
  Relationship.create!(name: relationship_name) unless Relationship.find_by(name: relationship_name)
end

#---------------------------EN USUARIOS - ROL AMINISTRADOR DE TODO (Super Admin de todo)------------------------------
unless User.find_by(email: 'ger@man.com')
  User.create!(
    first_name: 'Germán',
    last_name: 'Martínez',
    email: 'ger@man.com',
    password: 'asdasd',
    admin_role: true
  )
end

unless User.find_by(email: 'sergio@farias.com')
  User.create!(
    first_name: 'Sergio',
    last_name: 'Farías',
    email: 'sergio@farias.com',
    password: 'test123',
    admin_role: true
  )
end

unless User.find_by(email: 'esteban@page.com')
  User.create!(
    first_name: 'Esteban',
    last_name: 'Page',
    email: 'esteban@page.com',
    password: 'test123',
    admin_role: true
  )
end

#--------------Rol Dueño---------------------
user_owner = User.find_by(email: 'rol_duenio@puntosaltoque.com')
if user_owner.blank?
  user_owner = User.create!(
    first_name: 'Rol',
    last_name: 'Dueño',
    email: 'rol_duenio@puntosaltoque.com',
    password: '12345678',
    company_owner_role: true
  )
end

#--------------Rol Gerente---------------------
user_managment = User.find_by(email: 'rol_gerente@puntosaltoque.com')
if user_managment.blank?
  user_managment = User.create!(
    first_name: 'Rol',
  last_name: 'Gerente',
  email: 'rol_gerente@puntosaltoque.com',
  password: '12345678'
  )
end

#--------------Rol Intermedio---------------------
user_intermediate = User.find_by(email: 'rol_intermedio@puntosaltoque.com')
if user_intermediate.blank?
  user_intermediate = User.create!(
    first_name: 'Rol',
    last_name: 'Intermedio',
    email: 'rol_intermedio@puntosaltoque.com',
    password: '12345678',
  )
end

#--------------Rol Basico---------------------
user_basic = User.find_by(email: 'rol_basico@puntosaltoque.com')
if user_basic.blank?
  puts "entro aqui......"
  user_basic = User.create!(
    first_name: 'Rol',
    last_name: 'Basico',
    email: 'rol_basico@puntosaltoque.com',
    password: '12345678'
  )
end


puts user_basic.to_json

company = Company.find_by(name: 'Test')
if company.blank?
  company = Company.new(
    name: 'Test',
    active: true,
    observation: "Este es un comercio de prueba",
    user_id: user_owner.id
  )
  company.save

  Array(1..7).each do |day|
    company_setting = company.company_settings.new(
      day: day,
      conversion: 0,
      discount: 0
    )
    company_setting.save
  end
end

main_branch = company.branches.find_by(main: true)
if main_branch.blank?
  main_branch = Branch.new(
    name: 'Principal',
    main: true,
    city_id: 1,
    address: 'Belgrano 1800',
    company_id: company.id
  )
  main_branch.save
end

# Asociamos Sucursal principal de test con Usuarios---------------------

unless BranchUser.find_by(branch_id: main_branch.id, user_id: user_managment)
  puts "entro............."
  puts main_branch.to_json
  BranchUser.create!(
    branch_id: main_branch.id,
    user_id: user_managment.id,
    active: true,
    manager_role: true,
    intermediate_role: false,
    basic_role: false
  )
end

unless BranchUser.find_by(branch_id: main_branch.id, user_id: user_intermediate)
  BranchUser.create!(
    branch_id: main_branch.id,
    user_id: user_intermediate.id,
    active: true,
    manager_role: false,
    intermediate_role: true,
    basic_role: false
  )
end

unless BranchUser.find_by(branch_id: main_branch.id, user_id: user_basic)
  BranchUser.create!(
    branch_id: main_branch.id,
    user_id: user_basic.id,
    active: true,
    manager_role: false,
    intermediate_role: false,
    basic_role: true
  )
end
