# 再現Kitchen

マンガ、アニメ、小説や絵本などに出てくる料理の再現レシピサイトです。 <br>
ユーザーが再現したレシピを投稿できます。<br>
レスポンシブ対応しているのでスマホからもご確認いただけます。
<img width="1440" alt="Image" src="https://github.com/user-attachments/assets/7065d173-4880-4500-af37-733fb374ed8c" />
<img width="378" alt="Image" src="https://github.com/user-attachments/assets/17048879-1e03-4dcb-b762-6d5d4c0b59db" />

# URL
https://saigen-kitchen-4e3497eb9a40.herokuapp.com

# 使用技術
- Ruby 3.3.3
- Ruby on Rails 6.1.7.10
- Mysql 8.0.35
- HEROKU
- S3
- Docker/Docker-compose
- CircleCi CI/CD
- Rspec
- RakutenBooksTotalAPI

<img width="799" alt="Image" src="https://github.com/user-attachments/assets/44a482aa-6093-4f73-9374-45c9b983df70" />

# アプリについて
料理と漫画や小説といった好きなものを組み合わせたサービスを作りたいというところから始まりました。私自身、Youtubeで調べたり、作ったりするのが好きで楽しかったので、レシピサイトはたくさんありますが、作品の中で出てきた料理にレシピに絞りました。

# 機能紹介
- ログイン機能
deviseを使用したログイン機能です。ゲストログイン,メールアドレスログイン、グーグルログインを実装。
![Image](https://github.com/user-attachments/assets/78520f52-4a09-434c-826f-709e0a66d4b6)
- 投稿機能
レシピが投稿できます。RakutenBooksAPIを使って情報を取得できるようにしています。
![Image](https://d.kuku.lu/36ttmg53w)



# 機能一覧
- ユーザー登録、ログイン機能(devise)
- 投稿機能
  - 画像投稿(carirrewave)
- お気に入り機能
- コメント機能
- レシピ検索機能

# テスト
- Rspec
  - model spec
  - request spec
  - system spec
