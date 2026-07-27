class PdfNote < Node
  has_one_attached :file

  MAX_ITEMS_COUNT = 15
  MAX_FILE_SIZE = 100.megabytes
  ACCEPTED_CONTENT_TYPE = 'application/pdf'.freeze

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
      errors.add(:file, 'is too large (maximum is 100MB)')
    end

    unless file.content_type == ACCEPTED_CONTENT_TYPE
      errors.add(:file, 'must be a PDF')
    end
  end
end
