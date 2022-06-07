# Method

- `Object.send` で動的にメソッド呼び出しができる
    - コードの実行時に動的にメソッド呼び出しをすることを動的ディスパッチという
- 同様に `Object.define_method` で動的にメソッドを定義できる
    - e.g. `define_method "test_method" do return "This is test." end`
- メソッド探索の結果、何も見つからなかった場合は `method_missing` が呼ばれる
    - 通常のアプリケーションコードではオーバーライドすることは少ないが、gemなどでラッパーオブジェクトが実態のオブジェクトに処理を委譲する時にフォールバック先として書いたりする
- オブジェクトに `.hoge` が呼び出せるか確認するためには `respond_to?`
- `method_missing` のオーバーライドはメソッド探索を最後まで行った結果見つからなかった時に呼ばれるので、`method_missing` 内で他のメソッドを呼び出す実装にしていると、継承チェーン内で同名のメソッドがあった時に `method_missing` が呼ばれない
    - こういったケースでは必要最小限のメソッドだけ実装したクラスに `method_missing` を実装すればよく、このようなクラスのことをブランクスレートという
        - Rubyでは `BasicObject` がブランクスレートして利用しやすいオブジェクトの一つ
            - e.g. https://github.com/jimweirich/builder
## メモ

### 特異メソッド

>特異メソッド(singleton_method)とはクラスではなくある特定のオブジェクトに固有のメソッド

引用：[クラス／メソッドの定義 (Ruby 3.1 リファレンスマニュアル)](https://docs.ruby-lang.org/ja/latest/doc/spec=2fdef.html#singleton_method)

- クラスメソッドはクラスに定義された特異メソッドのこと。
- `#{定義対象のオブジェクト}.#{メソッド名}`で定義できる
```ruby
hoge = Hoge.new
def hoge.fuga
  "hogefuga"
end
hoge.fuga #=> "hogefuga"
```
- 特異メソッドは特異クラス（シングルトンクラス）に住んでいる。
  - 上記のようにメソッド定義をするとRubyが特異クラスを生成してそこにメソッドを定義している。
```ruby
hoge.fuga #=> "hogefuga"
```

### Object#extend

>引数で指定したモジュールのインスタンスメソッドを self の特異メソッドとして追加します。

[Object#extend (Ruby 3.1 リファレンスマニュアル)](https://docs.ruby-lang.org/ja/latest/method/Object/i/extend.html)
