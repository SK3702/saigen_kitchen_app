$(document).on('turbolinks:load', function() {
  // 検索ボタンがクリックされたときの処理
  $('#work_search_button').on('click', function(e) {
    e.preventDefault(); // 通常のフォーム送信を防ぐ
    const keyword = $('#work_search_field').val();
    if (keyword.length > 1) { // 2文字以上なら検索を実行
      $.ajax({
        url: '/recipes/work_search',
        method: 'GET',
        data: { keyword: keyword },
        dataType: 'json',
        success: function(data) {
          let suggestions = $('#work_suggestions');
          if (data.length === 0) {
            $('#work_suggestions').empty();
            // 検索結果がない場合はメッセージを表示
            suggestions.append(
              $('<li class="text-center py-3">').text("検索結果はありません。そのまま投稿してください。")
            );
          } else {
            suggestions.empty();
            data.forEach(function(work) {
              suggestions.append(
                $('<li class="border-bottom py-3 work-suggenstion">')
                .text(work.title + " (" + work.author + ") (" + work.type + ") ¥" + work.price)
                .data({
                  workTitle: work.title,
                  workAuthor: work.author,
                  workImage: work.image_url,
                  workPrice: work.price,
                  workUrl: work.url,
                })
              );
            });
          }
        },
        error: function(xhr, status, error) {
        }
      });
    }
  });

  $(document).off('click', '#work_suggestions li');

  // 検索結果の候補リストから作品を選択したとき
  $(document).on('click', '#work_suggestions li', function() {
    const workTitle = $(this).data('workTitle');
    const workAuthor = $(this).data('workAuthor');
    const workImage = $(this).data('workImage');
    const workPrice = $(this).data('workPrice');
    const workUrl = $(this).data('workUrl');

    // 例えば、表示用に workTitle と creator を表示する
    const displayHtml = `
      <p>${workTitle} (${workAuthor})</p>
      <img src="${workImage}" alt="作品イメージ" class="img-fluid" />
    `;
    $('#entered_work').html(displayHtml).addClass("text-center py-3 mt-2 bg-pink");
    // 隠しフィールドに各値をセット
    $('#recipe_work_title').val(workTitle);
    $('#recipe_work_author').val(workAuthor);
    $('#recipe_work_image').val(workImage);
    $('#recipe_work_price').val(workPrice);
    $('#recipe_work_url').val(workUrl);

    $('#work_suggestions').empty();
  });
});
