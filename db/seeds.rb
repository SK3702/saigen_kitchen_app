User.create!(
  [
    { email: "user1@example.com", password: "password", name: "User One", bio: "I love cooking!", avatar: "default.png" }
  ]
)
User.create!(
  [
    { email: "user2@example.com", password: "password", name: "User Two", bio: "料理が好きです。", avatar: "logo_pic.png" }
  ]
)

Category.create!(
  [
    { name: "マンガ" },
    { name: "アニメ" },
    { name: "小説・絵本" },
    { name: "その他" }
  ]
)

recipe = Recipe.create!(
  title: "ぐりとぐらのカステラパンケーキ",
  work_name: "ぐりとぐら",
  user: User.first,
  category: Category.find_by(name: "小説・絵本"),
  recipe_image: File.open(Rails.root.join("app/assets/images/pancake.jpg")),
  tip: "いい材料を使ってください。",
  servings_count: 2,
  ingredients_attributes: [
    { name: "卵", quantity: "2個" },
    { name: "グラニュー糖", quantity: "65g" },
    { name: "薄力粉", quantity: "65g" },
    { name: "牛乳", quantity: "大さじ1" },
    { name: "無塩バター", quantity: "15g" }
  ],
  instructions_attributes: [
    { step: 1, description: "卵をボウルに溶きほぐし、グラニュー糖を加え泡立てる。" },
    { step: 2, description: "牛乳とバターを60℃位に温めて①に加え、かき混ぜる。" },
    { step: 3, description: "薄力粉を入れ、さっくり混ぜて型に流す。" },
    { step: 4, description: "170℃のオーブンで約40分、表面が色づくまで焼いたら完成です。" }
  ]
)

recipe = Recipe.create!(
  title: "炭治郎が食べた山かけうどん",
  work_name: "鬼滅の刃",
  user: User.last,
  category: Category.find_by(name: "マンガ"),
  recipe_image: File.open(Rails.root.join("app/assets/images/udon.jpg")),
  tip: "簡単です。",
  servings_count: 1,
  ingredients_attributes: [
    { name: "冷凍うどん", quantity: "1玉" },
    { name: "めんつゆ(3倍濃縮)", quantity: "50cc" },
    { name: "水", quantity: "300cc" },
    { name: "山芋", quantity: "100g" },
    { name: "卵黄", quantity: "1個" },
    { name: "ねぎ", quantity: "適量" },
    { name: "刻み海苔", quantity: "適量" },
    { name: "わさび", quantity: "お好みの量" }
  ],
  instructions_attributes: [
    { step: 1, description: "鍋に水と麺つゆを入れ沸かす。その間に山芋を擦っておく。" },
    { step: 2, description: "つゆが沸いたら、麺を温める。" },
    { step: 3, description: "どんぶりに麺を移し、つゆ、山芋を山芋をかける。" },
    { step: 4, description: "卵黄、ねぎ、刻み海苔をかけ、わさびをお好みで添えたら完成です。" }
  ]
)

recipe = Recipe.create!(
  title: "ラピュタパン",
  work_name: "天空の城ラピュタ",
  user: User.first,
  category: Category.find_by(name: "アニメ"),
  recipe_image: File.open(Rails.root.join("app/assets/images/rapyuta_bread.jpg")),
  tip: "Lサイズの卵だとこぼれることがあるので、大きすぎない卵を使うことをお勧めします。",
  servings_count: 1,
  ingredients_attributes: [
    { name: "食パン", quantity: "1枚" },
    { name: "卵", quantity: "1個" },
    { name: "マヨネーズ", quantity: "適量" },
    { name: "塩", quantity: "適量" },
    { name: "胡椒", quantity: "適量" }
  ],
  instructions_attributes: [
    { step: 1, description: "食パンふちを2段ほどマヨネーズで囲います。" },
    { step: 2, description: "真ん中に卵を落とします。" },
    { step: 3, description: "塩、胡椒を振り、アルミホイルに乗せてトースターで6〜8分焼きます" }
  ]
)

puts "Success!"
