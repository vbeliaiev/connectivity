class AddContentTsvToNodes < ActiveRecord::Migration[7.1]
  def up
    # Generic plain-text column any node type can populate for search
    # purposes: Note stores its rich text body here (plain text extract),
    # PhotoGallery can later store a human-written description, etc.
    # Types that don't need it (Folder, PdfNote, VideoNote for now) simply
    # leave it blank.
    add_column :nodes, :content, :text

    # Generated (stored) tsvector column combining title + content, kept in
    # sync by Postgres itself whenever either column changes -- no
    # triggers/callbacks needed for the tsvector itself. `french` config is
    # used since site content is mostly French, so plural/singular and
    # other inflections match each other (e.g. "bulletin" / "bulletins").
    # Occasional English words or acronyms (e.g. "AG") still match fine,
    # since unrecognized tokens are kept as-is rather than dropped.
    execute <<-SQL.squish
      ALTER TABLE nodes
      ADD COLUMN content_tsv tsvector
      GENERATED ALWAYS AS (
        to_tsvector('french', coalesce(title, '') || ' ' || coalesce(content, ''))
      ) STORED
    SQL

    add_index :nodes, :content_tsv, using: :gin
  end

  def down
    remove_index :nodes, :content_tsv
    remove_column :nodes, :content_tsv
    remove_column :nodes, :content
  end
end
