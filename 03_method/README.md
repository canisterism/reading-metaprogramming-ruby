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
