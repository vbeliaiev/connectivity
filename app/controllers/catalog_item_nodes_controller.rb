class CatalogItemNodesController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_pundit_authorization

  before_action :set_node, only: :create
  before_action :set_catalog_item_node, only: :destroy

  # Accepts one or more catalog item ids (submitted as catalog_item_ids[]
  # by the "Associer au catalogue numérique" modal, which lets moderators
  # queue up several links before submitting the form once) and links each
  # of them to @node in a single request.
  def create
    authorize CatalogItemNode.new(node: @node)

    catalog_item_ids = Array(params[:catalog_item_ids]).reject(&:blank?)

    if catalog_item_ids.empty?
      redirect_to redirect_path_for(@node), alert: "Veuillez ajouter au moins un élément du catalogue à associer."
      return
    end

    linked_count = 0
    error_messages = []

    catalog_item_ids.each do |catalog_item_id|
      catalog_item = CatalogItem.find_by(id: catalog_item_id)

      if catalog_item.nil?
        error_messages << "Aucun élément du catalogue trouvé avec l'identifiant #{catalog_item_id}."
        next
      end

      catalog_item_node = CatalogItemNode.new(node: @node, catalog_item: catalog_item)

      if catalog_item_node.save
        linked_count += 1
      else
        error_messages << catalog_item_node.errors.full_messages.to_sentence
      end
    end

    notice = "#{linked_count} élément(s) du catalogue associé(s) avec succès." if linked_count.positive?
    alert = error_messages.to_sentence if error_messages.any?

    redirect_to redirect_path_for(@node), notice: notice, alert: alert
  end

  def destroy
    authorize @catalog_item_node

    node = @catalog_item_node.node
    @catalog_item_node.destroy!
    redirect_to redirect_path_for(node), notice: "L'association au catalogue numérique a été supprimée avec succès."
  end

  private

  def set_node
    @node = Node.find(params[:node_id])
  end

  def set_catalog_item_node
    @catalog_item_node = CatalogItemNode.find(params[:id])
  end

  # Every node subtype (Folder, Article, PhotoGallery, PdfNote, VideoNote)
  # has its own `show` route and controller action, so after linking or
  # unlinking a catalog item we always send the user back to the node's own
  # show page.
  def redirect_path_for(node)
    node
  end
end
