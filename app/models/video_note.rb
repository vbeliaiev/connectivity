class VideoNote < Node
  belongs_to :organisation
  has_one_attached :file

  MAX_ITEMS_COUNT = 15
  MAX_FILE_SIZE = 700.megabytes

  validates :title, presence: true
  validate :file_presence
  validate :acceptable_file

  private

  def file_presence
    errors.add(:file, 'must be attached') unless file.attached?
  end

  def acceptable_file
    return unless file.attached?

    if file.byte_size > MAX_FILE_SIZE
      errors.add(:file, 'is too large (maximum is 700MB)')
    end

    unless file.content_type.to_s.start_with?('video/')
      errors.add(:file, 'must be a video')
    end
  end
end
