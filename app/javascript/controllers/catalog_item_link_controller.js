import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="catalog-item-link"
//
// Powers the "Associer au catalogue numérique" modal: opens/closes like the
// image-modal/video-modal controllers, and validates the pasted catalog
// item link (or plain id) against the server as the user types, showing a
// green "found" label or a red "not found" label and enabling the submit
// button only once a matching catalog item has been found.
export default class extends Controller {
  static targets = [
    "modal",
    "input",
    "catalogItemIdField",
    "submitButton",
    "statusFound",
    "statusFoundLabel",
    "statusNotFound"
  ]
  static values = { baseUrl: String }

  open() {
    this.modalTarget.classList.remove("hidden")
  }

  close() {
    this.modalTarget.classList.add("hidden")
  }

  closeOnBackdrop(event) {
    if (event.target === this.modalTarget) this.close()
  }

  check() {
    clearTimeout(this.debounceTimer)
    this.debounceTimer = setTimeout(() => this.verify(), 300)
  }

  async verify() {
    const id = this.extractId(this.inputTarget.value)

    if (!id) {
      this.markUnknown()
      return
    }

    try {
      const response = await fetch(`${this.baseUrlValue}/${id}.json`, {
        headers: { Accept: "application/json" }
      })

      if (response.ok) {
        const data = await response.json()
        this.markFound(id, data.title)
      } else {
        this.markNotFound()
      }
    } catch (error) {
      this.markNotFound()
    }
  }

  // Accepts either a full catalog item URL (e.g.
  // "https://.../catalog_items/123") or a plain numeric id ("123").
  extractId(value) {
    const trimmed = value.trim()
    if (!trimmed) return null

    const pathMatch = trimmed.match(/catalog_items\/(\d+)/)
    if (pathMatch) return pathMatch[1]

    if (/^\d+$/.test(trimmed)) return trimmed

    return null
  }

  markFound(id, title) {
    this.catalogItemIdFieldTarget.value = id
    this.statusFoundLabelTarget.textContent = title ? `Trouvé : ${title}` : "Élément du catalogue trouvé"
    this.statusFoundTarget.classList.remove("hidden")
    this.statusNotFoundTarget.classList.add("hidden")
    this.submitButtonTarget.disabled = false
  }

  markNotFound() {
    this.catalogItemIdFieldTarget.value = ""
    this.statusFoundTarget.classList.add("hidden")
    this.statusNotFoundTarget.classList.remove("hidden")
    this.submitButtonTarget.disabled = true
  }

  markUnknown() {
    this.catalogItemIdFieldTarget.value = ""
    this.statusFoundTarget.classList.add("hidden")
    this.statusNotFoundTarget.classList.add("hidden")
    this.submitButtonTarget.disabled = true
  }
}
