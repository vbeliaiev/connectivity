import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="clipboard"
//
// Copies the text in `data-clipboard-text-value` to the clipboard when the
// element is clicked. Briefly swaps the default (copy) icon for a check
// icon to confirm the copy succeeded. Used on the catalog index rows so
// admins/moderators can grab a catalog item link with one click.
export default class extends Controller {
  static targets = ["default", "success", "message"]
  static values = { text: String }

  copy(event) {
    // The button lives next to a row-wide link; stop the click from
    // bubbling up and navigating to the catalog item page.
    event.preventDefault()
    event.stopPropagation()

    this.writeToClipboard(this.textValue).then(() => this.flashSuccess())
  }

  async writeToClipboard(text) {
    if (navigator.clipboard && window.isSecureContext) {
      await navigator.clipboard.writeText(text)
      return
    }

    // Fallback for non-secure contexts (e.g. plain http on a LAN) where
    // the async Clipboard API is unavailable.
    const textarea = document.createElement("textarea")
    textarea.value = text
    textarea.setAttribute("readonly", "")
    textarea.style.position = "absolute"
    textarea.style.left = "-9999px"
    document.body.appendChild(textarea)
    textarea.select()
    document.execCommand("copy")
    document.body.removeChild(textarea)
  }

  flashSuccess() {
    if (!this.hasDefaultTarget || !this.hasSuccessTarget) return

    this.defaultTarget.classList.add("hidden")
    this.successTarget.classList.remove("hidden")
    if (this.hasMessageTarget) this.messageTarget.classList.remove("hidden")

    clearTimeout(this.resetTimer)
    this.resetTimer = setTimeout(() => {
      this.successTarget.classList.add("hidden")
      this.defaultTarget.classList.remove("hidden")
      if (this.hasMessageTarget) this.messageTarget.classList.add("hidden")
    }, 1500)
  }
}
