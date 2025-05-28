class Node < ApplicationRecord
  has_many :children, class_name: 'Node', foreign_key: 'parent_id'
  belongs_to :parent, class_name: 'Node', optional: true
end
