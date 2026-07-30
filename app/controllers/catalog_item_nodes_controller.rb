class CatalogItemNodesController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_pundit_authorization

  before_action :set_node, only: :create
  before_action :set_catalog_item_node, only: :destroy

  def create
    catalog_item = CatalogItem.find_by(id: params[:catalog_item_id])
    @catalog_item_node = CatalogItemNode.new(node: @node, catalog_item: catalog_item)
    authorize @catalog_item_node

    if catalog_item.nil?
      redirect_to redirect_path_for(@node), alert: "Aucun élément du catalogue trouvé avec cet identifiant."
      return
    end

    if @catalog_item_node.save
      redirect_to redirect_path_for(@node), notice: "Le contenu a été associé au catalogue numérique avec succès."
    else
      redirect_to redirect_path_for(@node), alert: @catalog_item_node.errors.full_messages.to_sentence
    end
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

  # PdfNote and VideoNote are shown inline in their parent folder's (or the
  # home page's) content list rather than being browsed as standalone pages,
  # so after linking/unlinking a catalog item we send the user back there
  # instead of to the note's own show page. Every other node type (Article,
  # Folder, PhotoGallery) keeps its own show page as the redirect target.
  def redirect_path_for(node)
    case node
    when PdfNote, VideoNote
      node.parent_id ? folder_path(node.parent_id) : root_path
    else
      node
    end
  end
end
