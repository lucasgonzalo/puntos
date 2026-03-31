module RedisKeyHelper

  def get_value(redis_key)
    key_type = @redis.type(redis_key)

    case key_type
    when "string"
      value = @redis.get(redis_key)
    when "list"
      value = @redis.lrange(redis_key, 0, -1) # Obtiene todos los elementos de la lista
    when "set"
      value = @redis.smembers(redis_key) # Obtiene todos los miembros del conjunto
    when "hash"
      value = @redis.hgetall(redis_key) # Obtiene todos los campos y valores del hash
    else
      value = "Tipo no soportado: #{key_type}"
    end
    return value
  end

end
