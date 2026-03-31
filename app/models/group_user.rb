class GroupUser < ApplicationRecord
  belongs_to :group
  belongs_to :user

  validates :user_id, uniqueness: { scope: :group_id, message: 'ya está en esta entidad'}
end
