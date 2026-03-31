module Puntos
  VERSION = File.read(Rails.root.join('CHANGELOG.md')).match(/^## \[(\d+\.\d+\.\d+)\]/)[1] rescue '0.0.0'
end