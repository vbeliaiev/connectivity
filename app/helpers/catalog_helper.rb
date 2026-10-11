module CatalogHelper
  # Options for the catalog sort dropdown, as [label, value] pairs in the
  # order they should appear. Values come from CatalogItem::SORT_OPTIONS so
  # the UI can never offer a key the model doesn't know how to order by.
  def catalog_sort_options
    CatalogItem::SORT_OPTIONS.keys.map do |key|
      [t("catalog.show.sort_options.#{key}"), key]
    end
  end
end
