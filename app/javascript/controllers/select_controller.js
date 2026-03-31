//import { Controller } from "stimulus"
import { Controller } from "@hotwired/stimulus";

import { get } from "@rails/request.js"

export default class extends Controller {
  static targets = ["selectState", "selectCity"]
  static values = {
    url: String,
    url2: String,
    param: String,
    param2: String
  }

  connect() {
    if (this.selectStateTarget.id === "") {
      this.selectStateTarget.id = Math.random().toString(30)
    }
    if (this.selectCityTarget.id === "") {
      this.selectCityTarget.id = Math.random().toString(30)
    }
  }

  changeCountry(event) {
    let params = new URLSearchParams()
    params.append(this.paramValue, event.target.selectedOptions[0].value)
    params.append("target_states", this.selectStateTarget.id)
    params.append("target_cities", this.selectCityTarget.id)
    
    get(`${this.urlValue}?${params}`, {
      responseKind: "turbo-stream"
    })
  }

  changeState(event) {
    let params = new URLSearchParams()
    params.append(this.param2Value, event.target.selectedOptions[0].value)
    params.append("target_states", this.selectStateTarget.id)
    params.append("target_cities", this.selectCityTarget.id)

    get(`${this.url2Value}?${params}`, {
      responseKind: "turbo-stream"
    })
  }
}
