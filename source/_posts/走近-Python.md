---
title: 走近 Python (类比 JS)
copyright: true
abbrlink: a9d08041
date: 2017-10-31 08:53:14
tags: ['Python']
categories: ['Python']
---
![](http://with.muyunyun.cn/c5438d5b79ea49066234e0328fde04e1.jpg-muyy)

> 本文首发在 [个人博客](http://muyunyun.cn/posts/a9d08041/)

Python 是一门运用很广泛的语言，自动化脚本、爬虫，甚至在深度学习领域也都有 Python 的身影。作为一名前端开发者，也了解 ES6 中的很多特性借鉴自 Python (比如默认参数、解构赋值、Decorator等)，同时本文会对 Python 的一些用法与 JS 进行类比。不管是提升自己的知识广度，还是更好地迎接 AI 时代，Python 都是一门值得学习的语言。

<!--more-->

### 数据类型

在 Python 中，最常用的能够直接处理的数据类型有以下几种：

* 数字[整数(int)、浮点型(float)、长整型(long)、复数(complex)]
* 字符串(str)
* 布尔值(bool)
* 空值(None)

除此之外，Python 还提供了列表[list]、字典[dict] 等多种数据类型，这在下文中会介绍。

#### 类型转换与类型判断

与 JS 十分类似，python 也能实现不同数据类型间的强制与隐式转换，例子如下：

强制类型转换:
``` py
int('3') # 3
str(3.14) # '3.14'
float('3.14') # 3.14
# 区别于 JS 只有 Number 一种类型，Python 中数字中的不同类型也能相互强制转换
float(3) # 3.0
bool(3) # True
bool(0) # False
```

隐式类型转换:
``` py
1 + 1.0 # 2.0
1 + False # 1
1.0 + True # 2.0
# 区别于 JS 的 String + Number = String, py 中 str + int 会报错
1 + '1' # TypeError: cannot concatenate 'str' and 'int' objects
```

此外写代码的时候经常会需要判断值的类型，可以 使用 python 提供的 type() 函数获取变量的类型，或者使用 isinstance(x, type) 来判断 x 是否属于相应的 type 类型。
``` py
type(1.3) == float # True
isinstance('a', str) # True
isinstance(1.3, int) # False
isinstance(True, bool) # True
isinstance([], list) # True
isinstance({}, dict) # True
```

### 有序集合类型

集合是指包含一组元素的数据结构，有序集合即集合里面的元素是是按照顺序排列的，Python 中的有序集合大概有以下几类：list, tuple, str, unicode。

#### list 类型

Python 中 List 类型类似于 JS 中的 Array,

``` py
L = [1, 2, 3]
print L[-1] # '3'

L.append(4) # 末尾添加元素
print L # [1, 2, 3, 4]

L.insert(0, 'hi') # 指定索引位置添加元素
print L # ['hi', 1, 2, 3, 4]

L.pop() # 末尾移除元素 L.pop(2) ?????? 2 ???
print L # ['hi', 1, 2, 3]
```

#### tuple 类型

tuple 类型是另一种有序的列表，中文翻译为“ 元组 ”。tuple 和 list 非常类似，但是，tuple 一旦创建完毕，就不能修改了。

``` py
t = (1, 2, 3)
print t[0] # 1
t[0] = 11 # TypeError: 'tuple' object does not support item assignment

t = (1)
print t # 1  t 的结果是整数 1

t = (1,) # 为了避免出现如上有歧义的单元素 tuple，所以 Python 规定，单元素 tuple 要多加一个逗号“,”
print t # (1,)
```

### 无序集合类型

#### dict 类型

Python 中的 dict 类型类似于 JS 中的 {} (最大的不同是它是没有顺序的), 它有如下特点:

* 查找速度快 (无论 dict 有 10 个元素还是 10 万个元素，查找速度都一样)
* 占用内存大 (与 list 类型相反)
* dict 中的 key 不能重复
* dict 中存储的 key-value 序对是没有顺序的

``` py
d = {
    'a': 1,
    'b': 2,
    'c': 3
}

print d # {'a': 1, 'c': 3, 'b': 2}  可以看出打印出的序对没有按正常的顺序打出

# 遍历 dict
for key,value in d.items():
    print('%s: %s' % (key,value))
# a: 1
# c: 3
# b: 2
```

#### set 类型

有的时候，我们只想要 dict 的 key，不关心 key 对应的 value，而且要保证这个集合的元素不会重复，这时，set 类型就派上用场了。set 类型有如下特点：

* set 存储的元素和 dict 的 key 类似，必须是不变对象
* set 存储的元素也是没有顺序的

```py
s = set(['A', 'B', 'C', 'C'])
print s # set(['A', 'C', 'B'])

s.add('D')
print s # set(['A', 'C', 'B', 'D'])

s.remove('D')
print s # set(['A', 'C', 'B'])
```

### Python 中的迭代

在介绍完 Python 中的有序集合和无序集合类型后，必然存在遍历集合的 for 循环。但是和其它语言的标准 for 循环不同，Python 中的所有迭代是通过 for ... in 来完成的。以下给出一些常用的迭代 demos:

索引迭代：

``` py
L = ['apple', 'banana', 'orange']
for index, name in enumerate(L):  # enumerate() 函数把 ['apple', 'banana', 'orange'] 变成了类似 [(0, 'apple), (1, 'banana'), (2, 'orange')] 的形式
    print index, '-', name

# 0 - apple
# 1 - banana
# 2 - orange
```

迭代 dict 的 value:

``` py
d = { 'apple': 6, 'banana': 8, 'orange': 5 }
print d.values() # [6, 8, 5]
for v in d.values()
    print v
# 6
# 8
# 5
```

迭代 dict 的 key 和 value:

``` py
d = { 'apple': 6, 'banana': 8, 'orange': 5 }
for key, value in d.items()
    print key, ':', value
# apple : 6
# banana: 8
# orange: 5
```

### 切片操作符

Python 提供的切片操作符类似于 JS 提供的原生函数 slice()。有了切片操作符，大大简化了一些原来得用循环的操作。

``` py
L = ['apple', 'banana', 'orange', 'pear']
L[0:2] # ['apple', 'banana'] 取前 2 个元素
L[:2] # ['apple', 'banana'] 如果第一个索引是 0，可以省略
L[:] # ['apple', 'banana', 'orange', 'pear'] 只用一个 : ，表示从头到尾
L[::2] # ['apple', 'orange'] 第三个参数表示每 N 个取一个，这里表示从头开始，每 2 个元素取出一个来
```

### 列表生成器

如果要生成 [1x1, 2x2, 3x3, ..., 10x10] 怎么做？方法一是循环：

``` py
L = []
for x in range(1, 11):
    L.append(x * x)
```

但是循环太繁琐，而列表生成式则可以用一行语句代替循环生成上面的 list：

```py
# 把要生成的元素 x * x 放到前面，后面跟 for 循环，就可以把 list 创建出来
[x * x for x in range(1, 11)]
# [1, 4, 9, 16, 25, 36, 49, 64, 81, 100]
```

列表生成式的 for 循环后面还可以加上 if 判断(类似于 JS 中的 filter() 函数)，示例如下：

``` py
[x * x for x in range(1, 11) if x % 2 == 0]
# [4, 16, 36, 64, 100]
```

for 循环可以嵌套，因此，在列表生成式中，也可以用多层 for 循环来生成列表。

```py
[m + n for m in 'ABC' for n in '123']
# ['A1', 'A2', 'A3', 'B1', 'B2', 'B3', 'C1', 'C2', 'C3']
```

### Python 函数

#### 默认参数

JS 中 ES6 的 默认参数正是借鉴于 Python，用法如下：

``` py
def greet(name='World'):
    print 'Hello, ' + name + '.'

greet() # Hello, World.
greet('Python') # Hello, Python.
```

#### 可变参数

类似于 JS 函数中自动识别传入参数的个数，Python 也提供了定义可变参数，即在可变参数的名字前面带上个 `*` 号。

``` py
def fn(*args):
    print args

fn()  # ()
fn('a') # ('a',)
fn('a', 'b') # ('a', 'b')
```

Python 解释器会把传入的一组参数组装成一个 tuple 传递给可变参数，因此，在函数内部，直接把变量 args 看成一个 tuple 就好了。

#### 常用高阶函数

Python 中常用的函数 (map、reduce、filter) 的作用和 JS 中一致，只是用法稍微不同。

* map 函数: 接收一个函数 f 和一个 list，并通过把函数 f 依次作用在 list 的每个元素上，得到一个新的 list 并返回。

```py
def f(x):
    return x * x
print map(f, [1, 2, 3, 4, 5, 6, 7, 8, 9]) # [1, 4, 9, 16, 25, 36, 49, 64, 81]
```

* reduce 函数: 接收一个函数 f 和一个 list(可以接受第三个值作为初始值)，reduce() 对 list 的每个元素反复调用函数 f，并返回最终结果值。

```py
def f(x, y):
    return x * y

reduce(f, [1, 3, 5]) # 15
```

* filter 函数: 接收一个函数 f 和一个list，这个函数 f 的作用是对每个元素进行判断，返回 True或 False，filter() 根据判断结果自动过滤掉不符合条件的元素，返回由符合条件元素组成的新 list。

```py
def is_odd(x):
    return x % 2 == 1

filter(is_odd, [1, 4, 6, 7, 9, 12, 17]) # [1, 7, 9, 17]
```

#### 匿名函数

和 JS 的匿名函数不同的地方是，Python 的匿名函数中只能有一个表达式，且不能写 return。拿 map() 函数为例：

```py
map(lambda x: x * x, [1, 2, 3, 4, 5, 6, 7, 8, 9]) # [1, 4, 9, 16, 25, 36, 49, 64, 81]
```

关键词 lambda 表示匿名函数，冒号前面的 x 表示函数参数，可以看出匿名函数 `lambda x: x* x` 实际上就是:

``` py
def f(x):
    return x * x
```

#### 闭包

之前写过一些关于 JS 闭包的文章，比如 [深入浅出JavaScript之闭包（Closure）](http://www.cnblogs.com/MuYunyun/p/5930703.html)、以及 [读书笔记-你不知道的 JavaScript (上)](http://muyunyun.cn/posts/4a895cbd/)，Python 中闭包的定义和 JS 中的是一致的即：内层函数引用了外层函数的变量，然后返回内层函数。下面来看下 Py 中闭包之 for 循环经典问题：

``` py
# 希望一次返回3个函数，分别计算1x1,2x2,3x3:
def count():
    fs = []
    for i in range(1, 4):
        def f():
            return i * i
        fs.append(f)
    return fs

f1, f2, f3 = count() # 这种写法相当于 ES6 中的解构赋值
print f1(), f2(), f3() # 9 9 9
```

老问题了，f1(), f2(), f3() 结果不应该是 1, 4, 9 吗，实际结果为什么都是 9 呢？

原因就是当 count() 函数返回了 3 个函数时，这 3 个函数所引用的变量 i 的值已经变成了 3。由于 f1、f2、f3 并没有被调用，所以，此时他们并未计算 i*i，当 f1 被调用时，i 已经变为 3 了。

要正确使用闭包，就要确保引用的局部变量在函数返回后不能变。代码修改如下:

方法一: 可以理解为创建了一个封闭的作用域，i 的 值传给 j 之后，就和 i 没任何关系了。每次循环形成的闭包都存进了内存中。
```py
def count():
    fs = []
    for i in range(1, 4):
        def f(j):
            def g(): # 方法一
                return j * j
            return g
        r = f(i)
        fs.append(r)
    return fs

f1, f2, f3 = count()
print f1(), f2(), f3() # 1 4 9
```

方法二：思路比较巧妙，用到了默认参数 j 在函数定义时可以获取到 i 的值，虽然没有用到闭包，但是和方法一有异曲同工之处。
```py
def count():
    fs = []
    for i in range(1, 4):
        def f(j = i): # 方法二
            return j * j
        fs.append(f)
    return fs

f1, f2, f3 = count()
print f1(), f2(), f3() # 1 4 9
```

#### decorator 装饰器

ES6 的语法中的 decorator 正是借鉴了 Python 的 decorator。decorator 本质上就是`一个高阶函数，它接收一个函数作为参数，然后返回一个新函数`。

那装饰器的作用在哪呢？先上一段日常项目中用 ts 写的网关代码：

```js
@Post('/rider/detail')  // URL 路由
@log()                   // 打印日志
  @ResponseBody
  public async getRiderBasicInfo(
    @RequestBody('riderId') riderId: number,
    @RequestBody('cityId') cityId: number,
  ) {
    const result = await this.riderManager.findDetail(cityId, riderId)
    return result
  }
```

可以看出使用装饰器可以极大地简化代码，避免每个函数(比如日志、路由、性能检测)编写重复性代码。

回到 Python 上，Python 提供的 @ 语法来使用 decorator，`@ 等价于 f = decorate(f)`。下面来看看 @log() 在 Python 中的实现:

```py
# 我们想把调用的函数名字给打印出来
@log()
def factorial(n):
    return reduce(lambda x,y: x*y, range(1, n+1))
print factorial(10)

# 来看看 @log() 的定义
def log():
    def log_decorator(f):
        def fn(x):
            print '调用了函数' + f.__name__ + '()'
            return f(x)
        return fn
    return log_decorator

# 结果
# 调用了函数 factorial()
# 3628800
```

### class
#### 面向对象编程

面向对象编程是一种程序设计范式，基本思想是：用类定义抽象类型，然后根据类的定义创建出实例。在掌握其它语言的基础上，还是比较容易理解这块知识点的，比如从下面两种写法可以看出不同语言的语言特性间竟然有如此多的共性。

es6: (附：本文的主题是 python，所以只是初略展示下 js 中类的定义以及实例的创建，为了说明写法的相似性)
```js
class Person {
    constructor(name, age) {
        this.name = name
        this.age = age
    }
}

const child1 = new Person('Xiao Ming', 10)
```

Python: (核心要点写在注释中)
```py
# 定义一个 Person 类：根据 Person 类就可以造成很多 child 实例
class Person(object):
    address = 'Earth' # 类属性 (实例公有)
    def __init__(self, name, age): # 创建实例时，__init__()方法被自动调用
        self.name = name
        self.age = age
    def get_age(self): # 定义实例方法，它的第一个参数永远是 self，指向调用该方法的实例本身，其他参数和普通函数是一样的
        return self.age

child1 = Person('Xiao Ming', 10)
child2 = Person('Xiao Hong', 9)

print child1.name # 'Xiao Ming'
print child2.get_age() # 9
print child1.address # 'Earth'
print child2.address # 'Earth'
```

#### 继承

child 属于 Student 类，Student 类属于 People 类，这就引出了继承: 即获得了父类的方法属性后又能添加自己的方法属性。

```py
class Person(object):
    def __init__(self, name, age):
        self.name = name
        self.age = age

class Student(Person):
    def __init__(self, name, age, grade):
        super(Student, self).__init__(name, age) # 这里也能写成 Person.__init__(self, name, age)
        self.grade = grade

s = Student('Xiao Ming', 10, 90)
print s.name # 'Xiao Ming'
print s.grade # 90
```

可以看到子类在父类的基础上又增加了 grade 属性。我们可以再来看看 s 的类型。

```py
isinstance(s, Person)
isinstance(s, Student)
```

可以看出，Python 中在一条继承链上，一个实例可以看成它本身的类型，也可以看成它父类的类型。
