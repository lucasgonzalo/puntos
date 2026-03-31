//import { Controller } from "stimulus"
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {

  static targets = [ 'backgroundImageInput', 'backgroundImageError', 'backgroundImagePreview', 'existingBackgroundImage', 'fontOption', 'selectedFont', 'fontHiddenInput' ]

  connect() {
    console.log("catalogs_controller conected")
  }

  // disable/enable form submit
  _setSubmitDisabled(disabled) {
    const submitBtn = this.element.querySelector('input[type="submit"], button[type="submit"]');
    if (submitBtn) submitBtn.disabled = disabled;
  }

  validateBackgroundImage(event) {
    if (!this.hasBackgroundImageInputTarget || !this.hasBackgroundImageErrorTarget || !this.hasBackgroundImagePreviewTarget) {
      console.warn('catalogs controller: missing background image targets');
      return;
    }

    const input = this.backgroundImageInputTarget;
    const file = input.files[0];

    // clear previous messages/preview
    this.backgroundImageErrorTarget.textContent = '';
    this.backgroundImagePreviewTarget.innerHTML = '';
    // allow submit by default
    this._setSubmitDisabled(false);

    // show/hide existing attached preview depending on whether user selected a new file
    if (this.hasExistingBackgroundImageTarget) {
      if (file) {
        this.existingBackgroundImageTarget.style.display = 'none';
      } else {
        this.existingBackgroundImageTarget.style.display = '';
      }
    }

    if (!file) return;

    // allowed types (match products controller)
    const validTypes = ['image/jpeg', 'image/png', 'image/jpg', 'image/webp'];
    if (!validTypes.includes(file.type)) {
      this.backgroundImageErrorTarget.textContent = '❌ Formato no válido. Usa JPG, PNG o WEBP.';
      // prevent form submission for invalid format
      this._setSubmitDisabled(true);
      // do not clear input so user can replace it; keep preview empty
      return;
    }

    const img = new Image();
    const objectUrl = URL.createObjectURL(file);
    img.onload = () => {
      // require minimum dimensions: 1024px width AND/OR height (not less than 1024)
      if (img.width < 1024) {
        this.backgroundImageErrorTarget.textContent = `⚠️ Resolución insuficiente (${img.width}px) de ancho. Mínimo recomendado: 1024px de ancho y 600px de alto.`;
        // do NOT disable submit for dimension issues (non-blocking)
      }

      // show preview (small thumbnail)
      const thumb = document.createElement('img');
      thumb.alt = 'Vista previa';
      thumb.src = objectUrl;
      thumb.style.maxWidth = '300px';
      thumb.style.maxHeight = '200px';
      thumb.style.border = '1px solid #ccc';
      thumb.style.borderRadius = '6px';
      thumb.style.marginTop = '0.5rem';
      this.backgroundImagePreviewTarget.appendChild(thumb);

      thumb.onload = () => URL.revokeObjectURL(objectUrl);
    };

    img.onerror = () => {
      this.backgroundImageErrorTarget.textContent = '❌ No se pudo leer la imagen.';
      URL.revokeObjectURL(objectUrl);
    };

    img.src = objectUrl;
  }

  selectFont(event) {
    event.preventDefault();
    const font = event.currentTarget.dataset.font;
    this.fontHiddenInputTarget.value = font;
    this.selectedFontTarget.innerHTML = `<span style="font-family: '${font}', sans-serif;">${font} - Este es un texto de ejemplo</span>`;
  }
}