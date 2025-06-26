class Folder < Node
  belongs_to :organisation
  belongs_to :author, class_name: 'User', foreign_key: :user_id
end
