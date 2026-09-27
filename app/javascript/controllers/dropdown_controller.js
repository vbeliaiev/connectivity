import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="dropdown"
//
// Minimal disclosure menu: a button toggles a menu panel. Closes on outside
// click, on Escape (returning focus to the button), and before Turbo caches
// the page so a restored snapshot never shows the menu stuck open.
export default class extends Controller {
  static targets = ["button", "menu"]

  connect() {
    this.closeOnOutsideClick = this.closeOnOutsideClick.bind(this)
  }

  disconnect() {
    document.removeEventListener("click", this.closeOnOutsideClick)
  }

  toggle() {
    this.isOpen ? this.close() : this.open()
  }

  open() {
    this.menuTarget.hidden = false
    this.buttonTarget.setAttribute("aria-expanded", "true")
    document.addEventListener("click", this.closeOnOutsideClick)
  }

  close() {
    this.menuTarget.hidden = true
    this.buttonTarget.setAttribute("aria-expanded", "false")
    document.removeEventListener("click", this.closeOnOutsideClick)
  }

  closeOnEscape(event) {
    if (event.key !== "Escape" || !this.isOpen) return
    this.close()
    this.buttonTarget.focus()
  }

  closeOnOutsideClick(event) {
    if (!this.element.contains(event.target)) this.close()
  }

  get isOpen() {
    return !this.menuTarget.hidden
  }
}
