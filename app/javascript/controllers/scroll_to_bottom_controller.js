import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "message" ]

  messageTargetConnected(message) {
    if (message === message.parentElement.lastElementChild) {
      this.element.scrollTop = this.element.scrollHeight
    }
  }
}
