# Pin npm packages by running ./bin/importmap

# Algunos de los de aqui son externos
pin "application", preload: true

pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true


pin_all_from "app/javascript/controllers", under: "controllers"
pin "popper", to: 'popper.js', preload: true

pin "bootstrap", to: 'bootstrap.min.js', preload: true

pin "jquery", to: "https://code.jquery.com/jquery-3.7.1.min.js"

# Estos son de aqui numas del proyecto
pin "modules/greetings", to: "modules/greetings.js"

pin "rails-ujs", to: "rails-ujs.js"

pin "datatables.net", to: "https://cdn.datatables.net/2.1.8/js/dataTables.min.js", preload: true
pin "datatables-responsive.net", to: "https://cdn.datatables.net/responsive/3.0.3/js/dataTables.responsive.min.js", preload: true
pin "responsive.net", to: "https://cdn.datatables.net/responsive/3.0.3/js/responsive.dataTables.min.js", preload: true

pin "axios", to: "https://cdn.jsdelivr.net/npm/axios/dist/axios.min.js", preload: true

pin "@rails/request.js", to: "https://ga.jspm.io/npm:@rails/request.js@0.0.6/src/index.js"

pin "controllers/select_controller", to: "controllers/select_controller.js"
pin "controllers/companySetting_controller", to: "controllers/companySetting_controller.js"
pin "controllers/movements_controller", to: "controllers/movements_controller.js"

pin "apexcharts", to: "https://cdn.jsdelivr.net/npm/apexcharts", preload: true

# pin "chartkick", to: "chartkick.js"
# pin "Chart.bundle", to: "Chart.bundle.js"
pin "modules/datatables", to: "modules/datatables.js"

