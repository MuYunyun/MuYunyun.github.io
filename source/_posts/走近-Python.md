---
title: 走近 Python
copyright: true
abbrlink: a9d08041
date: 2017-10-31 08:53:14
tags: ['Python']
categories: ['Python']
---
![](http://oqhtscus0.bkt.clouddn.com/f27594afeda6b513ffec98c3e60ccbb0.jpg-muyy)

Python 是一门运用很广泛的语言，自动化脚本、爬虫，甚至在深度学习领域也都有 Python 的身影。作为一名前端开发者，也了解 JS 很多特性借鉴自 Python，比如默认参数、Decorator，同时本文会对 Python 的一些用法与 JS 进行类比。不管是提升自己的知识广度，还是更好地迎接 AI 时代，Python 都是一门值得学习的语言。

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

此外写代码的时候经常会需要判断值的类型，python 中提供的 isinstance(x, type) 可以用来判断 x 是否属于相应的 type 类型。
``` py
isinstance('a', str) # True
isinstance(1.3, int) # False
isinstance(True, bool) # True
isinstance([], list) # True
isinstance({}, dict) # True
```

### 有序集合类型

集合是指包含一组元素的数据结构，有序集合即集合里面的元素是是按照顺序排列的，Python 中的有序集合大概有以下几类：list, tuple, str, unicode。

#### list 类型

py 中 List 类型类似于 JS 中的 Array,

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

JS ES6 中的 默认参数正是借鉴于 Python，用法如下：

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

### map() 函数

Python 中的 map() 函数和 JS 中的 map() 函数实现的目的相同，但使用方法不同，它接收一个函数 f 和一个 list，并通过把函数 f 依次作用在 list 的每个元素上，得到一个新的 list 并返回。

```py
def f(x):
    return x*x
print map(f, [1, 2, 3, 4, 5, 6, 7, 8, 9]) # [1, 4, 9, 16, 25, 36, 49, 64, 81]
```










