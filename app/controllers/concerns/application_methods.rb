module ApplicationMethods
  extend ActiveSupport::Concern
  # Define instance methods here that can be used in every controller or in views, for models add 'include ApplicationMethods' on the file
  def datetime_in_time_zone(datetime, separator =':')
    datetime ? datetime.in_time_zone('America/Argentina/Buenos_Aires')&.strftime("%d/%m/%Y %H#{separator}%M") : '---'
  end

  def date_in_time_zone(datetime, separator =':')
    datetime ? datetime.in_time_zone('America/Argentina/Buenos_Aires')&.strftime("%d/%m/%Y") : '---'
  end

  def time_in_time_zone(datetime, separator =':')
    datetime ? datetime.in_time_zone('America/Argentina/Buenos_Aires')&.strftime("%H#{separator}%M") : '---'
  end

  def unformatted_datetime_in_time_zone(datetime)
    datetime ? datetime.in_time_zone('America/Argentina/Buenos_Aires') : '---'
  end
end