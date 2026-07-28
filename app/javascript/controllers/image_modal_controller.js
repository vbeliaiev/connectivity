import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="image-modal"
//
// Opens any image inside its scope in a full-size modal when clicked.
// Mirrors the video-modal controller's open/close/backdrop behavior.
export default class extends Controller {
  static targets = ["modal", "image", "caption"]

  connect() {
    // Scoped to any <img> inside this controller's element, excluding the
    // modal's own (initially empty) <img> so it never gets a listener
    // attached to itself.
    this.element.querySelectorAll("img:not([data-image-modal-target='image'])").forEach((img) => {
      img.classList.add("cursor-pointer")
      img.addEventListener("click", (event) => this.open(event))
    })
  }

  open(event) {
    const img = event.currentTarget
    const src = img.getAttribute("src")
    const caption = img.closest("figure")?.querySelector("figcaption")?.textContent?.trim()

    this.imageTarget.setAttribute("src", src)

    if (this.hasCaptionTarget) {
      this.captionTarget.textContent = caption || ""
      this.captionTarget.classList.toggle("hidden", !caption)
    }

    this.modalTarget.classList.remove("hidden")
  }

  close() {
    this.modalTarget.classList.add("hidden")
    this.imageTarget.setAttribute("src", "")
  }

  closeOnBackdrop(event) {
    if (event.target === this.modalTarget) {
      this.close()
    }
  }
}
