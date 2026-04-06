class AgentRequest < ApplicationRecord
  enum status: { pending: 'pending', approved: 'approved', cancelled: 'cancelled' }, _prefix: true
  belongs_to :customer
  belongs_to :branch
  belongs_to :user
  
  validates :customer_id, uniqueness: { scope: :status, if: -> { status_pending? }, message: 'ya tiene una solicitud pendiente' }
  scope :pending_first, -> { order(status: :asc, created_at: :desc) }


  def self.pending_for_customer?(customer_id)
    exists?(customer_id: customer_id, status: :pending)
  end

  def self.approved_for_customer?(customer_id)
    exists?(customer_id: customer_id, status: :approved)
  end

end