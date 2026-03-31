module BranchSettingsHelper
  def get_show_day(branch_setting)
    show_day = ''
    case branch_setting.day
    when 1
      show_day += 'Lunes'
    when 2
      show_day += 'Martes'
    when 3
      show_day += 'Miércoles'
    when 4
      show_day += 'Jueves'
    when 5
      show_day += 'Viernes'
    when 6
      show_day += 'Sabado'
    when 7
      show_day += 'Domingo'
    end
    show_day.html_safe
  end
end
