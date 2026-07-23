import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="rich-text-links"
//
// Makes every link inside rendered rich text (ActionText / Trix content)
// open in a new tab. Scoped to this controller's element only, so it does
// not affect any other links across the app.
export default class extends Controller {
  connect() {
    this.element.querySelectorAll("a").forEach((link) => {
      link.setAttribute("target", "_blank")
      link.setAttribute("rel", "noopener")
    })

    this.groupAdjacentImages()
  }

  // Wraps runs of 2+ image attachments that sit directly next to each
  // other (nothing but whitespace between them) in a flex container, so
  // they display side by side instead of Trix's default stacked layout.
  // A single image, or images separated by text/line breaks, are left
  // untouched and keep the default stacked/centered look. This is done in
  // JS (rather than CSS alone) so the wrapper is a real element we can
  // style unambiguously, instead of fighting Trix's own attachment/figure
  // sizing rules with sibling selectors.
  groupAdjacentImages() {
    const isImageAttachment = (node) =>
      node?.nodeType === 1 &&
      node.tagName === "ACTION-TEXT-ATTACHMENT" &&
      node.getAttribute("content-type")?.startsWith("image")

    const isSkippableWhitespace = (node) =>
      node?.nodeType === 3 && node.textContent.trim() === ""

    const attachments = Array.from(this.element.querySelectorAll("action-text-attachment"))
      .filter(isImageAttachment)

    const visited = new Set()

    attachments.forEach((attachment) => {
      if (visited.has(attachment)) return

      const group = [attachment]
      let current = attachment

      while (true) {
        let next = current.nextSibling
        while (isSkippableWhitespace(next)) next = next.nextSibling

        if (isImageAttachment(next)) {
          group.push(next)
          visited.add(next)
          current = next
        } else {
          break
        }
      }

      if (group.length > 1) {
        const wrapper = document.createElement("div")
        wrapper.className = "trix-content-image-row"
        group[0].parentNode.insertBefore(wrapper, group[0])
        group.forEach((node) => wrapper.appendChild(node))
      }
    })
  }
}
