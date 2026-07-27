class Folder < Node
  belongs_to :organisation
  belongs_to :author, class_name: 'User', foreign_key: :user_id
  validates :title, presence: true

  MAX_ITEMS_COUNT = 15

  # Number of items shown per content type when previewing a folder's
  # children on the home page overview (one level deep, no pagination;
  # instead a "+N more" link points to the folder's own show page).
  PREVIEW_ITEMS_COUNT = 20

  # Wraps a capped list of items alongside the true total count, so a view
  # can render the visible `items` and, if there are more, a "+N more" link.
  Preview = Struct.new(:items, :total_count, keyword_init: true) do
    def remaining_count
      total_count - items.size
    end

    def more?
      remaining_count > 0
    end
  end

  def child_folders(page)
    children.folders.ordered.page(page).per(MAX_ITEMS_COUNT)
  end

  def child_articles(page)
    children.articles.ordered.includes(:rich_text_page).page(page).per(Article::MAX_ITEMS_COUNT)
  end

  def child_pdf_notes(page)
    children.pdf_notes.ordered.includes(file_attachment: :blob).page(page).per(PdfNote::MAX_ITEMS_COUNT)
  end

  def child_video_notes(page)
    children.video_notes.ordered.includes(file_attachment: :blob).page(page).per(VideoNote::MAX_ITEMS_COUNT)
  end

  def child_photo_galleries(page)
    children.photo_galleries.ordered
      .includes(items: { image_attachment: :blob })
      .page(page).per(PhotoGallery::MAX_ITEMS_COUNT)
  end

  def child_folders_preview
    preview_for(children.folders.ordered)
  end

  def child_articles_preview
    preview_for(children.articles.ordered.includes(:rich_text_page))
  end

  def child_pdf_notes_preview
    preview_for(children.pdf_notes.ordered.includes(file_attachment: :blob))
  end

  def child_video_notes_preview
    preview_for(children.video_notes.ordered.includes(file_attachment: :blob))
  end

  def child_photo_galleries_preview
    preview_for(children.photo_galleries.ordered.includes(items: { image_attachment: :blob }))
  end

  private

  def preview_for(scope)
    Preview.new(items: scope.limit(PREVIEW_ITEMS_COUNT).to_a, total_count: scope.count)
  end
end
