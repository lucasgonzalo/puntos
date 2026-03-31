module AlertsHelper

  def get_status_alert(alert)
    badges = ''
    badges += '<span class=\'badge text-bg-success\'>Nueva</span>' if alert.status_not_read?
    badges += '<span class=\'badge text-bg-secondary\'>Leída</span>' if alert.status_read?
    badges.html_safe
  end

end
