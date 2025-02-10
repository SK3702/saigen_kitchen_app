$(document).on('turbolinks:load', function() {
  const ingredientsContainer = document.getElementById("ingredients-container");
  const instructionsContainer = document.getElementById("instructions-container");
  const pageType = document.body.dataset.page;

  function addIngredientForm() {
    const index = ingredientsContainer.querySelectorAll('.ingredient-group').length;
    const newIngredient = `
    <div class="ingredient-group">
      <div class="row g-3 mb-3 align-items-end">
        <div class="col-6">
          <input type="text" name="recipe[ingredients_attributes][${index}][name]" class="form-control form-pink" placeholder="例: トマト(20文字以内)">
        </div>
        <div class="col-5">
          <input type="text" name="recipe[ingredients_attributes][${index}][quantity]" class="form-control form-pink" placeholder="例: 100g(20文字以内)">
        </div>
        <div class="col-1">
          <input type="hidden" name="recipe[ingredients_attributes][${index}][_destroy]" value="false" id="destroy-ingredient-${index}">
          <button type="button" class="btn-close mb-2 remove-ingredient" aria-label="Close" data-target="#destroy-ingredient-${index}"></button>
        </div>
      </div>
    </div>
  `;
    ingredientsContainer.insertAdjacentHTML("beforeend", newIngredient);
  }

  function addInstructionForm() {
    const index = instructionsContainer.children.length;
    const newInstruction = `
      <div class="instruction-group">
        <div class="row g-3 mb-3 align-items-end">
          <div class="col-11">
            <label class="form-label">手順 ${index + 1}</label>
            <textarea name="recipe[instructions_attributes][${index}][description]" class="form-control form-pink" rows="2" placeholder="例: フライパンにオリーブオイルを熱し、トマトを炒める(100文字以内)"></textarea>
          </div>
          <div class="col-1">
            <input type="hidden" name="recipe[instructions_attributes][${index}][_destroy]" value="false" id="destroy-instruction-${index}">
            <button type="button" class="btn-close mb-3 remove-instruction" aria-label="Close" data-target="#destroy-instruction-${index}"></button>
          </div>
        </div>
      </div>
    `;
    instructionsContainer.insertAdjacentHTML("beforeend", newInstruction);
  }

  // 材料を追加
  $("#add-ingredient").on("click", function() {
    addIngredientForm();
  })

  // 手順を追加
  $("#add-instruction").on("click", function() {
    addInstructionForm();

    if (pageType === 'edit') {
      $(".instruction-group:not(:hidden)").each(function (index, group) {
        $(group).find("label.form-label").text(`手順 ${index + 1}`);
      });
      $(".instruction-group").each(function (index, group) {
        $(group).find("textarea").attr("name", `recipe[instructions_attributes][${index}][description]`);
      });
    }
  })

  if (pageType === 'new') {
    // 材料を削除
    $(document).on("click", ".remove-ingredient", function() {
      $(this).closest(".ingredient-group").remove();
    });

    // 手順を削除
    $(document).on("click", ".remove-instruction", function() {
      $(this).closest(".instruction-group").remove();

      $(".instruction-group").each(function(index, group) {
        $(group).find("label.form-label").text(`手順 ${index + 1}`);
        $(group).find("textarea").attr("name", `recipe[instructions_attributes][${index}][description]`);
      });
    });
  }

  if (pageType === 'edit') {
    //材料を削除
    $(document).on("click", ".remove-ingredient", function() {
      const destroyFieldSelector = $(this).data("target");
      const destroyField = $(destroyFieldSelector);
      destroyField.val("true");
      $(this).closest(".ingredient-group").hide();
    });

    //手順を削除
    $(document).on("click", ".remove-instruction", function() {
      const destroyFieldSelector = $(this).data("target");
      const destroyField = $(destroyFieldSelector);
      destroyField.val("true");
      $(this).closest(".instruction-group").hide();

      $(".instruction-group:not(:hidden)").each(function (index, group) {
        $(group).find("label.form-label").text(`手順 ${index + 1}`);
        $(group).find("textarea").attr("name", `recipe[instructions_attributes][${index}][description]`);
      });
    })
  }
})
