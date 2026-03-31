class Alert < ApplicationRecord
  
  enum category: { sales: 'Ventas', exchanges: 'Canjes' }, _prefix: true
  enum status: { not_read: 'Nueva', read: 'Leida' }, _prefix: true

  # ------------------------------Relaciones---------------------------------------------
  belongs_to :company

end
