TryOver3 = Module.new
# Q1
# 以下要件を満たすクラス TryOver3::A1 を作成してください。
# - run_test というインスタンスメソッドを持ち、それはnilを返す
# - `test_` から始まるインスタンスメソッドが実行された場合、このクラスは `run_test` メソッドを実行する
# - `test_` メソッドがこのクラスに実装されていなくても `test_` から始まるメッセージに応答することができる
# - TryOver3::A1 には `test_` から始まるインスタンスメソッドが定義されていない
module TryOver3
  class A1
    def run_test
      nil
    end

    def method_missing(name, *args)
      return run_test if start_with_test_?(name)

      super
    end

    private

    def start_with_test_?(string)
      !!(/test_/ =~ string)
    end
  end
end

# Q2
# 以下要件を満たす TryOver3::A2Proxy クラスを作成してください。
# - TryOver3::A2Proxy は initialize に TryOver3::A2 のインスタンスを受け取り、それを @source に代入する
# - TryOver3::A2Proxy は、@sourceに定義されているメソッドが自分自身に定義されているように振る舞う

module TryOver3
  class A2
    def initialize(name, value)
      instance_variable_set("@#{name}", value)
      self.class.attr_accessor name.to_sym unless respond_to? name.to_sym
    end
  end
end

class TryOver3::A2Proxy
  # @param source [TryOver3::A2]
  def initialize(source)
    @source = source
  end

  def method_missing(name, *args)
    @source.send(name, *args)
  end

  # respond_to?はゴーストメソッドを探せない
  # respond_to_missing?はrespond_to?内でフォールバック先として呼ばれる、ゴーストメソッドにも反応するためのメソッド
  # method_missingをオーバーライドするときはこっちにも実装するのがお作法
  # @see https://docs.ruby-lang.org/ja/latest/method/Object/i/respond_to_missing=3f.html)
  def respond_to_missing?(method, include_private = false)
    @source.respond_to?(method) || super
  end
end

# Q3
# 前回 OriginalAccessor の my_attr_accessor で定義した getter/setter に boolean の値が入っている場合には #{name}? が定義されるようなモジュールを実装しました。
# 今回は、そのモジュールに boolean 以外が入っている場合には hoge? メソッドが存在しないようにする変更を加えてください。
# （以下は god の模範解答を一部変更したものです。以下のコードに変更を加えてください）
module TryOver3::OriginalAccessor2
  def self.included(mod)
    mod.define_singleton_method :my_attr_accessor do |attr_sym|
      define_method attr_sym do
        @attr
      end

      define_method "#{attr_sym}=" do |value|
        if [true, false].include?(value)
          unless respond_to?("#{attr_sym}?")
            self.class.define_method "#{attr_sym}?" do
              @attr == true
            end
          end
        else
          self.class.undef_method attr_sym if respond_to? attr_sym
          self.class.undef_method "#{attr_sym}?" if respond_to? "#{attr_sym}?"
        end
        @attr = value
      end
    end
  end
end

# Q4
# 以下のように実行できる TryOver3::A4 クラスを作成してください。
# TryOver3::A4.runners = [:Hoge]
# TryOver3::A4::Hoge.run
# # => "run Hoge"

# test_q4_not_exists_runner_classがパスできなくて答え見た
class TryOver3::A4
  def self.runners=(args)
    @runners = args
  end

  def self.runners
    @runners
  end

  def self.const_missing(const_name)
    return super unless self.runners.include?(const_name)

    klass = Class.new do |c|
      c.define_singleton_method "run" do
        "run #{const_name}"
      end
    end

    const_set(const_name, klass)
  end
end

# Q5. チャレンジ問題！ 挑戦する方はテストの skip を外して挑戦してみてください。
#
# TryOver3::TaskHelper という include すると task というクラスマクロが与えられる以下のようなモジュールがあります。
module TryOver3::TaskHelper
  def self.included(klass)
    klass.define_singleton_method :task do |name, &task_block|
      new_klass = Class.new do
        define_singleton_method :run do
          puts "start #{Time.now}"
          block_return = task_block.call
          puts "finish #{Time.now}"
          block_return
        end
      end
      new_klass_name = name.to_s.split('_').map do |w|
        w[0] = w[0].upcase
        w
      end.join
      const_set(new_klass_name, new_klass)
    end
  end
end

# TryOver3::TaskHelper は include することで以下のような使い方ができます
class TryOver3::A5Task
  include TryOver3::TaskHelper

  task :foo do
    'foo'
  end
end
# irb(main):001:0> A3Task::Foo.run
# start 2020-01-07 18:03:10 +0900
# finish 2020-01-07 18:03:10 +0900
# => "foo"

# 今回 TryOver3::TaskHelper では TryOver3::A5Task::Foo のように Foo クラスを作らず TryOver3::A5Task.foo のようにクラスメソッドとして task で定義された名前のクラスメソッドでブロックを実行するように変更したいです。
# 現在 TryOver3::TaskHelper のユーザには TryOver3::A5Task::Foo.run のように生成されたクラスを使って実行しているユーザが存在します。
# 今回変更を加えても、その人たちにはこれまで通り生成されたクラスのrunメソッドでタスクを実行できるようにしておいて、warning だけだしておくようにしたいです。
# TryOver3::TaskHelper を修正してそれを実現してください。 なお、その際、クラスは実行されない限り生成されないものとします。
#
# 変更後想定する使い方
# メソッドを使ったケース
# irb(main):001:0> TryOver3::A5Task.foo
# start 2020-01-07 18:03:10 +0900
# finish 2020-01-07 18:03:10 +0900
# => "foo"
#
# クラスのrunメソッドを使ったケース
# irb(main):001:0> TryOver3::A5Task::Foo.run
# Warning: TryOver3::A5Task::Foo.run is deprecated
# start 2020-01-07 18:03:10 +0900
# finish 2020-01-07 18:03:10 +0900
# => "foo"
