// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails

// Importmap: Carga Stimulus desde el mapa de importación
// import { Application } from "@hotwired/stimulus"
// import { definitionsFromContext } from "@hotwired/stimulus-loading"

// Inicializa Stimulus
// const application = Application.start()
// const context = require.context("controllers", true, /\.js$/)
// application.load(definitionsFromContext(context))

import { Application } from "@hotwired/stimulus"

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

export { application }

import "apexcharts";

import "./axios_setup";

import "rails-ujs";

import "@hotwired/turbo-rails";

import "controllers";

import "popper";

import "bootstrap";

import "jquery";

import { greet } from "./modules/greetings";
greet("Juan");

//import "./modules/datatables";
import { initializeTables } from "./modules/datatables";

window.initializeTables = initializeTables;

document.addEventListener("turbo:load", () => {
  initializeTables();
});




