class Post < ApplicationRecord
  validates :title, presence: true
  validates :content, presence: true

  after_create_commit { broadcast_prepend_to "posts" }
  after_update_commit { broadcast_replace_to "posts" }
  after_destroy_commit{ broadcast_remove_to "posts"}
end
