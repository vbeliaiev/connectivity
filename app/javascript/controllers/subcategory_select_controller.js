import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="subcategory-select"
//
// Fills the subcategory <select> with the subcategories of the chosen
// category, and keeps it disabled until a category that has at least one
// subcategory is selected. The options are rendered server-side as a
// { categoryId: [[name, id], ...] } map so no extra request is needed.
export default class extends Controller {
  static targets = ["category", "subcategory"]
  static values = { options: Object }

  refresh() {
    const subcategories = this.optionsValue[this.categoryTarget.value] || []
    const select = this.subcategoryTarget
    const placeholder = select.options[0]

    select.replaceChildren(placeholder)
    subcategories.forEach(([name, id]) => select.add(new Option(name, id)))
    select.value = ""
    select.disabled = subcategories.length === 0
  }
}
