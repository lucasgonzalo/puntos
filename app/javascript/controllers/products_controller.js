import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    'productType',
    'priceField',
    'filter',
    'imageInput',
    'imageError',
    'imagePreview',
    'dimensions'
  ];

  connect() {
    console.log("products_controller connected");
    if (this.hasProductTypeTarget) {
      this.updatePriceField();
    }
  }

  // ---------- image validation ----------
  validateImage(event) {
    // guard: make sure image targets exist in the DOM
    if (!this.hasImageInputTarget || !this.hasImageErrorTarget || !this.hasImagePreviewTarget) {
      console.warn('products controller: missing image targets');
      return;
    }

    const input = this.imageInputTarget;
    const file = input.files[0];

    this.imageErrorTarget.textContent = '';
    this.imagePreviewTarget.innerHTML = '';

    if (!file) return;

    // 1) allowed types
    const validTypes = ['image/jpeg', 'image/png', 'image/jpg', 'image/webp'];
    if (!validTypes.includes(file.type)) {
      this.imageErrorTarget.textContent = '❌ Formato no válido. Usa JPG, PNG o WEBP.';
      input.value = '';
      return;
    }

    // 2) load image and validate dimensions/ratio
    const img = new Image();
    const objectUrl = URL.createObjectURL(file);
    img.onload = () => {
      // maximum dimensions
      if (img.width > 2000 || img.height > 2000) {
        this.imageErrorTarget.textContent = `❌ Imagen demasiado grande (${img.width}x${img.height}). Máximo: 2000px de ancho o alto.`;
        input.value = '';
        URL.revokeObjectURL(objectUrl);
        return;
      }

      // aspect ratio check
      const ratio = img.width / img.height;
      const allowedRatios = [3 / 2, 4 / 3, 5 / 4, 16 / 9];
      const tolerance = 0.15; // ±15%
      const ratioOK = allowedRatios.some(r => Math.abs(ratio - r) <= tolerance);

      if (!ratioOK) {
        this.imageErrorTarget.textContent =
          `❌ Relación de aspecto inválida, su imagen se verá pequeña o recortada.Tamaño actual: (${img.width}x${img.height}), ratio: ${ratio.toFixed(2)}. ` +
          `Se recomienda ~3:2(1.5), ~4:3(1.33), ~5:4(1.25) o 16:9(1.78). Tolerancia ±15%.`;
        // note: we do NOT clear the input so user can still see preview and decide
      }

      // show preview
      const thumb = document.createElement('img');
      thumb.alt = 'Vista previa';
      thumb.src = objectUrl;
      thumb.style.maxWidth = '200px';
      thumb.style.maxHeight = '200px';
      thumb.style.border = '1px solid #ccc';
      thumb.style.borderRadius = '6px';
      thumb.style.marginTop = '0.5rem';
      this.imagePreviewTarget.appendChild(thumb);

      // revoke object URL after preview image loads to free memory
      thumb.onload = () => URL.revokeObjectURL(objectUrl);
    };

    img.onerror = () => {
      this.imageErrorTarget.textContent = '❌ No se pudo leer la imagen.';
      input.value = '';
      URL.revokeObjectURL(objectUrl);
    };

    img.src = objectUrl;
  }

  filterTable() {
    if (!this.hasFilterTarget) return;
    const filterValue = this.filterTarget.value;
    const rows = this.element.querySelectorAll("tbody tr");

    rows.forEach(row => {
      const button = row.querySelector("td:nth-child(3) turbo-frame button");
      const status = button ? button.dataset.productStatus : null;
      row.style.display = (filterValue === "all" || status === filterValue) ? "" : "none";
    });
  }

  selectedType(event) {
    if (this.hasProductTypeTarget) this.updatePriceField();
  }

  updatePriceField() {
    if (!this.hasProductTypeTarget || !this.hasPriceFieldTarget) return;
    const selectedType = this.productTypeTarget.value;
    const priceField = this.priceFieldTarget;

    if (selectedType === 'points') {
      priceField.value = '';
      priceField.disabled = true;
      priceField.required = false;
    } else if (selectedType === 'currency_points') {
      priceField.disabled = false;
      priceField.required = true;
    }
  }
}
