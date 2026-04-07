import "jquery";
import "datatables.net";
import "datatables-responsive.net";
import "responsive.net";


export function initializeTables() {

  // ----------- Tabla de Paises ------------
  const countriesTable = document.getElementById("countries-table");
  if (countriesTable) {
    document.addEventListener("turbo:before-cache", () => {
      if (countriesTable && $.fn.DataTable.isDataTable(countriesTable)) {
        $(countriesTable).DataTable().destroy(); // Destruye el DataTable
      }
    });
    new DataTable(countriesTable, {
      responsive: true,
      language: {
        url: "/datatables/i18n/es-MX.json"
      }
    });
  }

  // ----------- Tabla de Provincias ------------
  const statesTable = document.getElementById("states-table");
  if (statesTable) {
    document.addEventListener("turbo:before-cache", () => {
      if (statesTable && $.fn.DataTable.isDataTable(statesTable)) {
        $(statesTable).DataTable().destroy(); // Destruye el DataTable
      }
    });
    new DataTable(statesTable, {
      responsive: true,
      order: [[2, "asc"]],
      language: {
        url: "/datatables/i18n/es-MX.json"
      },
      autoWidth: false
    });
  }

  // ----------- Tabla de Ciudades ------------
  const citiesTable = document.getElementById("cities-table");
  if (citiesTable) {
    document.addEventListener("turbo:before-cache", () => {
      if (citiesTable && $.fn.DataTable.isDataTable(citiesTable)) {
        $(citiesTable).DataTable().destroy(); // Destruye el DataTable
      }
    });
    new DataTable(citiesTable, {
      responsive: true,
      order: [[1, "asc"]],
      language: {
        url: "/datatables/i18n/es-MX.json"
      }
    });
  }

  // ----------- Tabla de Comercios ------------
  const companiesTable = document.getElementById("companies-table");
  if (companiesTable) {
    document.addEventListener("turbo:before-cache", () => {
      if (companiesTable && $.fn.DataTable.isDataTable(companiesTable)) {
        $(companiesTable).DataTable().destroy(); // Destruye el DataTable
      }
    });
    new DataTable(companiesTable, {
      responsive: true,
      language: {
        url: "/datatables/i18n/es-MX.json"
      }
    });
  }

  // ----------- Tabla de Catalogos ------------
  const catalogsTable = document.getElementById("catalogs-table");
  if (catalogsTable) {
    document.addEventListener("turbo:before-cache", () => {
      if (catalogsTable && $.fn.DataTable.isDataTable(catalogsTable)) {
        $(catalogsTable).DataTable().destroy(); // Destruye el DataTable
      }
    });
    new DataTable(catalogsTable, {
      responsive: true,
      language: {
        url: "/datatables/i18n/es-MX.json"
      }
    });
  }

  // ----------- Tabla de Movimientos ------------
  const movementsTable = document.getElementById("movements-table");
  if (movementsTable) {
    document.addEventListener("turbo:before-cache", () => {
      if (movementsTable && $.fn.DataTable.isDataTable(movementsTable)) {
        $(movementsTable).DataTable().destroy(); // Destruye el DataTable
      }
    });
    new DataTable(movementsTable, {
      order: [0, "desc"],
      language: {
        url: "/datatables/i18n/es-MX.json"
      },
      columnDefs: [
        { targets: 0, visible: false, searchable: false },
        { targets: [5, 6, 7, 8, 9], type: "num" }
      ],
      responsive: true
    });
  }

  // ----------- Tabla de Alertas ------------
  const alertsTable = document.getElementById("alerts-table");
  if (alertsTable) {
    document.addEventListener("turbo:before-cache", () => {
      if (alertsTable && $.fn.DataTable.isDataTable(alertsTable)) {
        $(alertsTable).DataTable().destroy(); // Destruye el DataTable
      }
    });
    new DataTable(alertsTable, {
      responsive: true,
      order: [[0, "desc"]],
      language: {
        url: "/datatables/i18n/es-MX.json"
      },
      columnDefs: [{ targets: 0, visible: false, searchable: false }]
    });
  }

  // ----------- Tabla de Alertas de Sucursales------------
  const branchalertsTable = document.getElementById("branchalerts-table");
  if (branchalertsTable) {
    document.addEventListener("turbo:before-cache", () => {
      if (branchalertsTable && $.fn.DataTable.isDataTable(branchalertsTable)) {
        $(branchalertsTable).DataTable().destroy(); // Destruye el DataTable
      }
    });
    new DataTable(branchalertsTable, {
      responsive: true,
      order: [[0, "desc"]],
      language: {
        url: "/datatables/i18n/es-MX.json"
      },
      columnDefs: [{ targets: 0, visible: false, searchable: false }]
    });
  }

  // ----------- Tabla de Clientes------------
  const customersTable = document.getElementById("customers-table");
  if (customersTable) {
    document.addEventListener("turbo:before-cache", () => {
      if (customersTable && $.fn.DataTable.isDataTable(customersTable)) {
        $(customersTable).DataTable().destroy(); // Destruye el DataTable
      }
    });
    new DataTable(customersTable, {
      responsive: true,
      language: {
        url: "/datatables/i18n/es-MX.json"
      }
    });
  }

  // ----------- Tabla de Usuarios de Sucursal------------
  const branchusersTable = document.getElementById("branchusers-table");
  if (branchusersTable) {
    document.addEventListener("turbo:before-cache", () => {
      if (branchusersTable && $.fn.DataTable.isDataTable(branchusersTable)) {
        $(branchusersTable).DataTable().destroy(); // Destruye el DataTable
      }
    });
    new DataTable(branchusersTable, {
      responsive: true,
      language: {
        url: "/datatables/i18n/es-MX.json"
      }
    });
  }

  // ----------- Tabla de Personas------------
  const peopleTable = document.getElementById("people-table");
  if (peopleTable) {
    document.addEventListener("turbo:before-cache", () => {
      if (peopleTable && $.fn.DataTable.isDataTable(peopleTable)) {
        $(peopleTable).DataTable().destroy(); // Destruye el DataTable
      }
    });
    new DataTable(peopleTable, {
      responsive: true,
      language: {
        url: "/datatables/i18n/es-MX.json"
      }
    });
  }

  // ----------- Tabla de Usuarios------------
  const usersTable = document.getElementById("users-table");
  if (usersTable) {
    document.addEventListener("turbo:before-cache", () => {
      if (usersTable && $.fn.DataTable.isDataTable(usersTable)) {
        $(usersTable).DataTable().destroy(); // Destruye el DataTable
      }
    });
    new DataTable(usersTable, {
      responsive: true,
      language: {
        url: "/datatables/i18n/es-MX.json"
      }
    });
  }

  // ----------- Tabla de Parentezco------------
  const relationshipsTable = document.getElementById("relationships-table");
  if (relationshipsTable) {
    document.addEventListener("turbo:before-cache", () => {
      if (relationshipsTable && $.fn.DataTable.isDataTable(relationshipsTable)) {
        $(relationshipsTable).DataTable().destroy(); // Destruye el DataTable
      }
    });
    new DataTable(relationshipsTable, {
      responsive: true,
      language: {
        url: "/datatables/i18n/es-MX.json"
      }
    });
  }

  // ----------- Tabla de Cuenta Corriente------------
  const currentaccountsTable = document.getElementById("currentaccounts-table");
  if (currentaccountsTable) {
    document.addEventListener("turbo:before-cache", () => {
      if (currentaccountsTable && $.fn.DataTable.isDataTable(currentaccountsTable)) {
        $(currentaccountsTable).DataTable().destroy(); // Destruye el DataTable
      }
    });
    new DataTable(currentaccountsTable, {
      responsive: true,
      order: [[0, "desc"]],
      language: {
        url: "/datatables/i18n/es-MX.json"
      },
      columnDefs: [{ targets: 0, visible: false, searchable: false }]
    });
  }

  // ----------- Tabla de Redis------------
  const rediskeysTable = document.getElementById("rediskeys-table");
  if (rediskeysTable) {
    document.addEventListener("turbo:before-cache", () => {
      if (rediskeysTable && $.fn.DataTable.isDataTable(rediskeysTable)) {
        $(rediskeysTable).DataTable().destroy(); // Destruye el DataTable
      }
    });
    new DataTable(rediskeysTable, {
      responsive: true,
      language: {
        url: "/datatables/i18n/es-MX.json"
      }
    });
  }

  // ----------- Tabla de Products------------
  const productsTable = document.getElementById("products-table");
  if (productsTable) {
    document.addEventListener("turbo:before-cache", () => {
      if (productsTable && $.fn.DataTable.isDataTable(productsTable)) {
        $(productsTable).DataTable().destroy(); // Destruye el DataTable
      }
    });
    new DataTable(productsTable, {
      responsive: true,
      language: {
        url: "/datatables/i18n/es-MX.json"
      }
    });
  }

  // ----------- Tabla de Solicitudes de Agente ------------
  const agentrequestsTable = document.getElementById("agent-requests-table");
  if (agentrequestsTable) {
    document.addEventListener("turbo:before-cache", () => {
      if (agentrequestsTable && $.fn.DataTable.isDataTable(agentrequestsTable)) {
        $(agentrequestsTable).DataTable().destroy();
      }
    });
    new DataTable(agentrequestsTable, {
      responsive: true,
      order: [[0, "desc"]],
      language: {
        url: "/datatables/i18n/es-MX.json"
      },
      columnDefs: [{ targets: 0, visible: false, searchable: false }]
    });
  }


}






