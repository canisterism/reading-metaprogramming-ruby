# Q1.
# 次の動作をする A1 class を実装する
# - "//" を返す "//"メソッドが存在すること

class A1
  define_method "//" do
    "//"
  end
end

# Q2.
# 次の動作をする A2 class を実装する
# - 1. "SmartHR Dev Team"と返すdev_teamメソッドが存在すること
# - 2. initializeに渡した配列に含まれる値に対して、"hoge_" をprefixを付与したメソッドが存在すること
# - 2で定義するメソッドは下記とする
#   - 受け取った引数の回数分、メソッド名を繰り返した文字列を返すこと
#   - 引数がnilの場合は、dev_teamメソッドを呼ぶこと
# - また、2で定義するメソッドは以下を満たすものとする
#   - メソッドが定義されるのは同時に生成されるオブジェクトのみで、別のA2インスタンスには（同じ値を含む配列を生成時に渡さない限り）定義されない

class A2
  def initialize(names)
    names.each do |name|
      method_name = "hoge_#{name}"
      self.define_singleton_method method_name do |n|
        return dev_team if n.nil?

        method_name * n
      end
    end
  end

  def dev_team
    "SmartHR Dev Team"
  end
end

# Q3.
# 次の動作をする OriginalAccessor モジュール を実装する
# - OriginalAccessorモジュールはincludeされたときのみ、my_attr_accessorメソッドを定義すること
# - my_attr_accessorはgetter/setterに加えて、boolean値を代入した際のみ真偽値判定を行うaccessorと同名の?メソッドができること

# 以下分からなすぎて答え見た
module OriginalAccessor
  # includeされた時に呼ばれるフックメソッド
  # klassはincludeを実行したクラス
  def self.included(klass)
    # object#extend(module)はレシーバの特異クラスにmoduleをincludeする
    klass.extend(ClassMethod)
  end

  module ClassMethod
    def my_attr_accessor(name)
      define_method name do
        instance_variable_get("@#{name}")
      end

      define_method "#{name}=" do |value|
        if [true, false].include?(value)
          define_singleton_method "#{name}?" do
            !!send(name)
          end
        end
        instance_variable_set("@#{name}", value)
      end
    end
  end
end
