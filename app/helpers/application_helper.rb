module ApplicationHelper
  # Renders an icon-only link styled as a small round button, used for
  # inline "Edit" actions instead of a full text button.
  def edit_icon_button(path, extra_class: "")
    link_to path, class: "inline-flex items-center justify-center w-9 h-9 rounded-full text-gray-500 hover:text-gray-900 hover:bg-gray-100 #{extra_class}", title: "Edit", "aria-label": "Edit" do
      content_tag(:svg, xmlns: "http://www.w3.org/2000/svg", width: "18", height: "18", viewBox: "0 0 24 24", fill: "none", stroke: "currentColor", "stroke-width": "2", "stroke-linecap": "round", "stroke-linejoin": "round", class: "lucide lucide-pencil") do
        raw('<path d="M17 3a2.85 2.83 0 1 1 4 4L7.5 20.5 2 22l1.5-5.5Z"/><path d="m15 5 4 4"/>')
      end
    end
  end

  # Renders an icon-only submit button styled as a small round button, used
  # for inline "Destroy" actions instead of a full text button.
  def destroy_icon_button(record_or_path, extra_class: "")
    button_to record_or_path, method: :delete, form_class: "inline-flex items-center", class: "inline-flex items-center justify-center w-9 h-9 rounded-full text-gray-500 hover:text-red-600 hover:bg-red-50 cursor-pointer #{extra_class}", title: "Destroy", "aria-label": "Destroy", data: { turbo_confirm: "Are you sure?" } do
      content_tag(:svg, xmlns: "http://www.w3.org/2000/svg", width: "18", height: "18", viewBox: "0 0 24 24", fill: "none", stroke: "currentColor", "stroke-width": "2", "stroke-linecap": "round", "stroke-linejoin": "round", class: "lucide lucide-trash-2") do
        raw('<path d="M3 6h18"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6"/><path d="M8 6V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/><line x1="10" x2="10" y1="11" y2="17"/><line x1="14" x2="14" y1="11" y2="17"/>')
      end
    end
  end
end
