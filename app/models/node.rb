class Node < ApplicationRecord
  has_many :children, class_name: 'Node', foreign_key: 'parent_id'
  belongs_to :parent, class_name: 'Node', optional: true
  belongs_to :author, class_name: 'User', foreign_key: :user_id

  enum visibility_level: { internal: 0, public_visibility: 1 }

  scope :folders, -> { where(type: 'Folder') }
  scope :notes, -> { where(type: 'Note') }
  scope :pdf_notes, -> { where(type: 'PdfNote') }
  scope :video_notes, -> { where(type: 'VideoNote') }
  scope :photo_galleries, -> { where(type: 'PhotoGallery') }
  scope :ordered, -> { order(Arel.sql('position ASC NULLS LAST'), created_at: :desc) }
  scope :root_records, -> { where(parent: nil) }

  # Full text search on `title` + `content` using Postgres FTS (content_tsv
  # is a generated/stored tsvector column, see migration
  # AddContentTsvToNodes). `websearch_to_tsquery` accepts natural,
  # multi-word user input (e.g. "annual report 2024") and treats it as an
  # AND of terms, so results are ranked by relevance via ts_rank.
  scope :content_search, ->(query) {
    return none if query.blank?

    tsquery = sanitize_sql_array(["websearch_to_tsquery('french', ?)", query])
    where("content_tsv @@ #{tsquery}").order(Arel.sql("ts_rank(content_tsv, #{tsquery}) DESC"))
  }

  GENERIC_FOLDER_NAME = 'Generic'.freeze

  def self.generic_folder_for(user_id, organisation_id: nil)
    organisation_id ||= User.find(user_id).personal_organisation.id
    find_or_create_by(title: GENERIC_FOLDER_NAME, position: -999, user_id: user_id, organisation_id: organisation_id)
  end

  def generic?
    title == GENERIC_FOLDER_NAME
  end

  # Returns the chain of ancestors from the root folder down to (but not
  # including) this node. Used to build breadcrumb navigation based purely
  # on the parent/child hierarchy (no reliance on request referer).
  def ancestors
    parent ? parent.ancestors + [parent] : []
  end
end
