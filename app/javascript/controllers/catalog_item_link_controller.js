import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="catalog-item-link"
//
// Powers the "Associer au catalogue numérique" modal: opens/closes like the
// image-modal/video-modal controllers, and validates the pasted catalog
// item link (or plain id) against the server as the user types, showing a
// green "found" label or a red "not found" label and enabling the "Ajouter"
// button only once a matching catalog item has been found. Found items are
// queued in a pending list (with a hidden catalog_item_ids[] field each) so
// several links can be added before submitting the form once via
// "Associer".
export default class extends Controller {
  static targets = [
    "modal",
    "input",
    "addButton",
    "pendingList",
    "pendingFields",
    "submitButton",
    "statusFound",
    "statusFoundLabel",
    "statusNotFound"
  ]
  static values = { baseUrl: String }

  connect() {
    this.pendingIds = new Set()
    this.foundItem = null
  }

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
    this.foundItem = { id, title }
    this.statusFoundLabelTarget.textContent = title ? `Trouvé : ${title}` : "Élément du catalogue trouvé"
    this.statusFoundTarget.classList.remove("hidden")
    this.statusNotFoundTarget.classList.add("hidden")
    this.addButtonTarget.disabled = this.pendingIds.has(id)
  }

  markNotFound() {
    this.foundItem = null
    this.statusFoundTarget.classList.add("hidden")
    this.statusNotFoundTarget.classList.remove("hidden")
    this.addButtonTarget.disabled = true
  }

  markUnknown() {
    this.foundItem = null
    this.statusFoundTarget.classList.add("hidden")
    this.statusNotFoundTarget.classList.add("hidden")
    this.addButtonTarget.disabled = true
  }

  // Queues the currently found catalog item into the pending list, clears
  // the input so another link can be pasted right away, and leaves the
  // "Associer" button enabled as soon as there's at least one pending item.
  add() {
    if (!this.foundItem || this.pendingIds.has(this.foundItem.id)) return

    const { id, title } = this.foundItem
    this.pendingIds.add(id)
    this.renderPendingItem(id, title)

    this.inputTarget.value = ""
    this.inputTarget.focus()
    this.markUnknown()
    this.submitButtonTarget.disabled = false
  }

  remove(event) {
    const id = event.currentTarget.dataset.id
    this.pendingIds.delete(id)
    event.currentTarget.closest("li").remove()
    this.pendingFieldsTarget.querySelector(`input[data-id="${id}"]`)?.remove()
    this.submitButtonTarget.disabled = this.pendingIds.size === 0
  }

  renderPendingItem(id, title) {
    const hiddenField = document.createElement("input")
    hiddenField.type = "hidden"
    hiddenField.name = "catalog_item_ids[]"
    hiddenField.value = id
    hiddenField.dataset.id = id
    this.pendingFieldsTarget.appendChild(hiddenField)

    const li = document.createElement("li")
    li.className = "flex items-center justify-between gap-2 border border-gray-300 rounded-md px-3 py-2"

    const label = document.createElement("span")
    label.className = "font-medium"
    label.textContent = title || `Élément du catalogue #${id}`
    li.appendChild(label)

    const removeButton = document.createElement("button")
    removeButton.type = "button"
    removeButton.className = "inline-flex items-center justify-center w-9 h-9 rounded-full text-gray-500 hover:text-red-600 hover:bg-red-50 cursor-pointer flex-shrink-0"
    removeButton.title = "Retirer"
    removeButton.setAttribute("aria-label", "Retirer")
    removeButton.dataset.id = id
    removeButton.dataset.action = "catalog-item-link#remove"
    removeButton.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-trash-2"><path d="M3 6h18"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6"/><path d="M8 6V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/><line x1="10" x2="10" y1="11" y2="17"/><line x1="14" x2="14" y1="11" y2="17"/></svg>'
    li.appendChild(removeButton)

    this.pendingListTarget.appendChild(li)
  }
}
