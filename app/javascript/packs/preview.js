$(document).on('turbolinks:load', function() {
  const pageType = document.body.dataset.page;

  function createImageHTML(blob) {
    const imageElement = document.getElementById("new-image");
    imageElement.innerHTML = "";
    const blobImage = document.createElement('img');
    blobImage.setAttribute('class', 'img-fluid rounded mx-auto recipe-image-size d-block');
    blobImage.setAttribute('src', blob);
    blobImage.setAttribute('alt', '新しい料理画像');
    imageElement.appendChild(blobImage);
  }

  const imageUpload = document.getElementById("recipe_recipe_image");
  if (imageUpload) {
    imageUpload.addEventListener("change", function(e) {
      const file = e.target.files[0];
      if (file) {
        const blob = window.URL.createObjectURL(file);
        createImageHTML(blob);
      } else {
        document.getElementById("new-image").innerHTML = "";
      }
    });
  }

  if (pageType === 'edit') {
    const currentImage = document.getElementById("current-image")
    if (currentImage) {
      imageUpload.addEventListener("change", function() {
        currentImage.remove();
      })
    }
  }
});
