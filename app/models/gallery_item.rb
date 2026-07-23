# GalleryItem is a generic "item within a collection" record. It is kept
# deliberately decoupled from any specific collection type (via the
# polymorphic `gallery` association) so it can be reused for future
# collection-like features (e.g. video playlists), not just photo galleries.
#
# It is also kept extensible on purpose: likes/comments are not implemented
# yet, but this model is a natural place to hang `has_many :comments` etc.
# later without needing to restructure the schema.
class GalleryItem < ApplicationRecord
  belongs_to :gallery, polymorphic: true, touch: true
  has_one_attached :image

  MAX_FILE_SIZE = 30.megabytes

  validates :cover, inclusion: { in: [true, false] }
  validate :image_presence
  validate :acceptable_image

  scope :ordered, -> { order(Arel.sql('position ASC NULLS LAST'), created_at: :asc) }
  scope :covers, -> { where(cover: true) }

  private

  def image_presence
    errors.add(:image, 'must be attached') unless image.attached?
  end

  def acceptable_image
    return unless image.attached?

    if image.byte_size > MAX_FILE_SIZE
      errors.add(:image, 'is too large (maximum is 30MB)')
    end

    unless image.content_type.to_s.start_with?('image/')
      errors.add(:image, 'must be an image')
    end
  end
end
