import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="video-modal"
export default class extends Controller {
  static targets = ["modal", "source", "player", "title"]

  open(event) {
    const { url, type, title } = event.currentTarget.dataset

    this.sourceTarget.setAttribute("src", url)
    this.sourceTarget.setAttribute("type", type)
    this.titleTarget.textContent = title || ""
    this.playerTarget.load()

    this.modalTarget.classList.remove("hidden")
  }

  close() {
    this.modalTarget.classList.add("hidden")
    this.playerTarget.pause()
    this.sourceTarget.setAttribute("src", "")
    this.playerTarget.load()
  }

  closeOnBackdrop(event) {
    if (event.target === this.modalTarget) {
      this.close()
    }
  }
}
