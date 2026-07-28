module ApplicationHelper
  VISIBILITY_LABELS = {
    "internal" => "Privé (réservé aux adhérents connectés)",
    "public_visibility" => "Public (visible sans connexion)"
  }.freeze

  # Chain of nodes to render as a breadcrumb, from the root folder down to
  # (and including) the given node. Built purely from the parent/child
  # hierarchy, never from request referer.
  def breadcrumb_nodes(node)
    node.ancestors + [node]
  end

  def visibility_label(level)
    VISIBILITY_LABELS.fetch(level.to_s, level.to_s.capitalize)
  end

  # Prefixes a node's title with "[public]" when it's flagged as public
  # content, but only for moderators/admins (so they can tell at a glance
  # which content is publicly visible to signed-out users). Regular members
  # and anonymous visitors just see the plain title.
  def node_title(node)
    return node.title unless node.public_visibility?
    return node.title unless current_user&.moderator? || current_user&.admin?

    "[public] #{node.title}"
  end

  # Renders an icon-only link styled as a small round button, used for
  # inline "Edit" actions instead of a full text button. Pass `label` to
  # also render a text label inside the same clickable link.
  def edit_icon_button(path, extra_class: "", label: nil)
    classes = label.present? ? "inline-flex items-center gap-1 px-2 h-9 rounded-full text-gray-500 hover:text-gray-900 hover:bg-gray-100 #{extra_class}" : "inline-flex items-center justify-center w-9 h-9 rounded-full text-gray-500 hover:text-gray-900 hover:bg-gray-100 #{extra_class}"
    link_to path, class: classes, title: "Edit", "aria-label": "Edit" do
      safe_join([
        content_tag(:svg, xmlns: "http://www.w3.org/2000/svg", width: "18", height: "18", viewBox: "0 0 24 24", fill: "none", stroke: "currentColor", "stroke-width": "2", "stroke-linecap": "round", "stroke-linejoin": "round", class: "lucide lucide-pencil") do
          raw('<path d="M17 3a2.85 2.83 0 1 1 4 4L7.5 20.5 2 22l1.5-5.5Z"/><path d="m15 5 4 4"/>')
        end,
        (content_tag(:span, label, class: "text-sm") if label.present?)
      ].compact)
    end
  end

  # Renders an icon-only submit button (globe/lock) that toggles a node's
  # visibility_level between public and internal, styled to match
  # edit_icon_button/destroy_icon_button. Pass `label` to also render a text
  # label inside the same clickable button.
  def toggle_visibility_button(node, extra_class: "", label: nil)
    to_public = !node.public_visibility?
    path = toggle_visibility_path_for(node)
    title = to_public ? "Rendre public" : "Rendre privé"
    confirm = to_public ? "Rendre ce contenu public ? Il sera visible sans connexion." : "Rendre ce contenu privé ? Il ne sera plus visible sans connexion."
    classes = label.present? ? "inline-flex items-center gap-1 px-2 h-9 rounded-full text-gray-500 hover:text-red-600 hover:bg-red-50 cursor-pointer #{extra_class}" : "inline-flex items-center justify-center w-9 h-9 rounded-full text-gray-500 hover:text-red-600 hover:bg-red-50 cursor-pointer #{extra_class}"

    button_to path, method: :patch, form_class: "inline-flex items-center", class: classes, title: title, "aria-label": title, data: { turbo_confirm: confirm } do
      safe_join([
        (to_public ? globe_icon : lock_icon),
        (content_tag(:span, label, class: "text-sm") if label.present?)
      ].compact)
    end
  end

  def toggle_visibility_path_for(node)
    case node
    when PdfNote then toggle_visibility_pdf_note_path(node)
    when VideoNote then toggle_visibility_video_note_path(node)
    else
      raise ArgumentError, "toggle_visibility is not supported for #{node.class}"
    end
  end

  def globe_icon
    content_tag(:svg, xmlns: "http://www.w3.org/2000/svg", width: "18", height: "18", viewBox: "0 0 24 24", fill: "none", stroke: "currentColor", "stroke-width": "2", "stroke-linecap": "round", "stroke-linejoin": "round", class: "lucide lucide-globe") do
      raw('<circle cx="12" cy="12" r="10"/><path d="M12 2a14.5 14.5 0 0 0 0 20 14.5 14.5 0 0 0 0-20"/><path d="M2 12h20"/>')
    end
  end

  def lock_icon
    content_tag(:svg, xmlns: "http://www.w3.org/2000/svg", width: "18", height: "18", viewBox: "0 0 24 24", fill: "none", stroke: "currentColor", "stroke-width": "2", "stroke-linecap": "round", "stroke-linejoin": "round", class: "lucide lucide-lock") do
      raw('<rect width="18" height="11" x="3" y="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/>')
    end
  end

  # Renders an icon-only submit button styled as a small round button, used
  # for inline "Destroy" actions instead of a full text button. Pass `label`
  # to also render a text label inside the same clickable button.
  def destroy_icon_button(record_or_path, extra_class: "", label: nil)
    classes = label.present? ? "inline-flex items-center gap-1 px-2 h-9 rounded-full text-gray-500 hover:text-red-600 hover:bg-red-50 cursor-pointer #{extra_class}" : "inline-flex items-center justify-center w-9 h-9 rounded-full text-gray-500 hover:text-red-600 hover:bg-red-50 cursor-pointer #{extra_class}"
    button_to record_or_path, method: :delete, form_class: "inline-flex items-center", class: classes, title: "Destroy", "aria-label": "Destroy", data: { turbo_confirm: "Are you sure?" } do
      safe_join([
        content_tag(:svg, xmlns: "http://www.w3.org/2000/svg", width: "18", height: "18", viewBox: "0 0 24 24", fill: "none", stroke: "currentColor", "stroke-width": "2", "stroke-linecap": "round", "stroke-linejoin": "round", class: "lucide lucide-trash-2") do
          raw('<path d="M3 6h18"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6"/><path d="M8 6V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/><line x1="10" x2="10" y1="11" y2="17"/><line x1="14" x2="14" y1="11" y2="17"/>')
        end,
        (content_tag(:span, label, class: "text-sm") if label.present?)
      ].compact)
    end
  end
end
