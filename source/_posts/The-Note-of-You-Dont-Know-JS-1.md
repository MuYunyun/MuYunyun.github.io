---
title: 读书笔记-你不知道的 JavaScript (上)
copyright: true
abbrlink: 4a895cbd
date: 2017-06-06 22:15:01
tags: ['读书笔记','JavaScript']
categories: ['JavaScript']
---
![](http://with.muyunyun.cn/a56029ee73c05e0f2897e6a1b574dc52.jpg-muyy)

《你不知道的JavaScript》系列丛书给出了很多颠覆以往对JavaScript认知的点, 读完上卷，受益匪浅，于是对其精华的知识点进行了梳理。
<!--more-->

## 什么是作用域
作用域是一套规则，用于确定在何处以及如何查找变量。
### 编译原理
JavaScript是一门编译语言。在传统编译语言的流程中，程序中一段源代码在执行之前会经历三个步骤，统称为“编译”。
* 分词/词法分析
  将字符串分解成有意义的代码块，代码块又称词法单元。比如程序`var a = 2;`会被分解为`var、a、=、2、;`
* 解析/语法分析
  将词法单元流转换成一个由元素逐级嵌套所组成的代表了程序语法接口的书，又称“抽象语法树”。
* 代码生成
  将抽象语法树转换为机器能够识别的指令。

### 理解作用域
作用域 分别与编译器、引擎进行配合完成代码的解析
* 引擎执行时会与作用域进行交流，确定RHS与LHS查找具体变量，如果查找不到会抛出异常。
* 编译器负责语法分析以及生成代码。
* 作用域负责收集并维护所有变量组成的一系列查询，并确定当前执行的代码对这些变量的访问权限。

对于 `var a = 2` 这条语句，首先编译器会将其分为两部分，一部分是 `var a`，一部分是 `a = 2`。编译器会在编译期间执行 var a，然后到作用域中去查找 a 变量，如果 a 变量在作用域中还没有声明，那么就在作用域中声明 a 变量，如果 a 变量已经存在，那就忽略 var a 语句。然后编译器会为 a = 2 这条语句生成执行代码，以供引擎执行该赋值操作。所以我们平时所提到的变量提升，无非就是利用这个先声明后赋值的原理而已！

### 异常
对于 `var a = 10` 这条赋值语句，实际上是为了查找变量 a， 并且将 10 这个数值赋予它，这就是 `LHS` 查询。 对于 `console.log(a)` 这条语句，实际上是为了查找 a 的值并将其打印出来，这是 `RHS` 查询。

为什么区分 `LHS` 和 `RHS` 是一件重要的事情？
在非严格模式下，LHS 调用查找不到变量时会创建一个全局变量，RHS 查找不到变量时会抛出 ReferenceError。 在严格模式下，LHS 和 RHS 查找不到变量时都会抛出 ReferenceError。

## 作用域的工作模式
作用域共有两种主要的工作模型。第一种是最为普遍的，被大多数编程语言所采用的词法作用域( JavaScript 中的作用域就是词法作用域)。另外一种是动态作用域，仍有一些编程语言在使用(比如Bash脚本、Perl中的一些模式等)。

### 词法作用域
词法作用域是一套关于引擎如何寻找变量以及会在何处找到变量的规则。词法作用域最重要的特征是它的定义过程发生在代码的书写阶段(假设没有使用 eval() 或 with )。来看示例代码:
``` js
function foo() {
  console.log(a);  // 2
}

function bar() {
  var a = 3;
  foo();
}

var a = 2;

bar()
```
词法作用域让foo()中的a通过RHS引用到了全局作用域中的a，因此会输出2。

### 动态作用域
而动态作用域只关心它们从何处调用。换句话说，作用域链是基于调用栈的，而不是代码中的作用域嵌套。因此，如果 JavaScript 具有动态作用域，理论上，下面代码中的 foo() 在执行时将会输出3。
``` js
function foo() {
  console.log(a);  // 3
}

function bar() {
  var a = 3;
  foo();
}

var a = 2;

bar()
```

## 函数作用域
### 匿名与具名
对于函数表达式一个最熟悉的场景可能就是回调函数了，比如
```js
setTimeout( function() {
  console.log("I waited 1 second!")
}, 1000 )
```
这叫作`匿名函数表达式`。函数表达式可以匿名，而函数声明则不可以省略函数名。匿名函数表达式书写起来简单快捷,很多库和工具也倾向鼓励使用这种风格的代码。但它也有几个缺点需要考虑。
* 匿名函数在栈追踪中不会显示出有意义的函数名,使得调试很困难。
* 如果没有函数名,当函数需要引用自身时只能使用已经过期的 arguments.callee 引用,比如在递归中。另一个函数需要引用自身的例子,是在事件触发后事件监听器需要解绑自身。
* 匿名函数省略了对于代码可读性 / 可理解性很重要的函数名。一个描述性的名称可以让代码不言自明。

始终给函数表达式命名是一个最佳实践:
```js
setTimeout( function timeoutHandler() { // 我有名字了
  console.log("I waited 1 second!")
}, 1000 )
```

## 提升
### 先有声明还是先有赋值
考虑以下代码：
``` js
a = 2;

var a;

console.log(a); // 2
```
考虑另外一段代码
``` js
console.log(a); // undefined

var a = 2;
```
我们习惯将 var a = 2; 看作一个声明，而实际上 JavaScript 引擎并不这么认为。它将 var a 和 a = 2 当作两个单独的声明，第一个是编译阶段的任务，而第二个是执行阶段的任务。
这意味着无论作用域中的声明出现在什么地方，都将在代码本身被执行前首先进行处理。可以将这个过程形象地想象成所有的声明（变量和函数）都会被“移动”到各自作用域的最顶端，这个过程称为提升。

可以看出，先有声明后有赋值。

再来看以下代码：
``` js
foo();  // TypeError
bar();  // ReferenceError

var foo = function bar() {
  // ...
};
```
这个代码片段经过提升后，实际上会被理解为以下形式:
``` js
var foo;

foo();  // TypeError
bar();  // ReferenceError

foo = function() {
  var bar = ...self...
  // ...
};
```
这段程序中的变量标识符 foo() 被提升并分配给全局作用域，因此 foo() 不会导致 ReferenceError。但是 foo 此时并没有赋值(如果它是一个`函数声明而不是函数表达式就会赋值`)。foo()由于对 undefined 值进行函数调用而导致非法操作，因此抛出 TypeError 异常。另外即时是具名的函数表达式，名称标识符(这里是 bar )在赋值之前也无法在所在作用域中使用。

## 闭包
之前写过关于闭包的一篇文章[深入浅出JavaScript之闭包(Closure)](http://www.cnblogs.com/MuYunyun/p/5930703.html)
### 循环和闭包
要说明闭包，for 循环是最常见的例子。
``` js
for (var i = 1; i <= 5; i++) {
  setTimeout( function timer() {
    console.log(i);
  }, i*1000 )
}
```
正常情况下，我们对这段代码行为的预期是分别输出数字 1~5，每秒一次，每次一个。但实际上，这段代码在运行时会以每秒一次的频率输出五次6。

它的缺陷在于：根据作用域的工作原理，尽管循环中的五个函数是在各个迭代中分别定义的，但是它们都被封闭在一个共享的全局作用域中，因此实际上只有一个i。因此我们需要更多的闭包作用域。我们知道IIFE会通过声明并立即执行一个函数来创建作用域，我们来进行改进：
``` js
for (var i = 1; i <= 5; i++) {
  (function() {
    var j = i;
    setTimeout( function timer() {
      console.log(j);
    }, j*1000 )
  })();
}
```
还可以对这段代码进行一些改进：
``` js
for (var i = 1; i <= 5; i++) {
  (function(j) {
    setTimeout( function timer() {
      console.log(j);
    }, j*1000 )
  })(i);
}
```
在迭代内使用 IIFE 会为每个迭代都生成一个新的作用域，使得延迟函数的回调可以将新的作用域封闭在每个迭代内部，每个迭代中都会含有一个具有正确值的变量供我们访问。

#### 重返块作用域
我们使用 IIFE 在每次迭代时都创建一个新的作用域。换句话说，每次迭代我们都需要一个块作用域。我们知道 let 声明可以用来劫持块作用域，那我们可以进行这样改：
``` js
for (var i = 1; i <= 5; i++) {
  let j = i;
  setTimeout( function timer() {
    console.log(j);
  }, j*1000 )
}
```
本质上这是将一个块转换成一个可以被关闭的作用域。

此外，for循环头部的 let 声明还会有一个特殊行为。这个行为指出每个迭代都会使用上一个迭代结束时的值来初始化这个变量。
``` js
for (let i = 1; i <= 5; i++) {
  setTimeout( function timer() {
    console.log(i);
  }, i*1000 )
}
```

## this全面解析
之前写过一篇[深入浅出JavaScript之this](http://www.cnblogs.com/MuYunyun/p/5932024.html)。我们知道this是在运行时进行绑定的，并不是在编写时绑定，它的上下文取决于函数调用时的各种条件。this的绑定和函数声明的位置没有任何关系，只取决于函数的调用方式。

### this词法
来看下面这段代码的问题：
``` js
var obj = {
  id: "awesome",
  cool: function coolFn() {
    console.log(this.id);
  }
};

var id = "not awesome";

obj.cool();  // awesome

setTimeout( obj.cool, 100); // not awesome
```
obj.cool() 与 setTimeout( obj.cool, 100 ) 输出结果不一样的原因在于 cool() 函数丢失了同 this 之间的绑定。解决方法最常用的是 var self = this;
``` js
var obj = {
  count: 0,
  cool: function coolFn() {
    var self = this;

    if (self.count < 1) {
      setTimeout( function timer(){
        self.count++;
        console.log("awesome?");
      }, 100)
    }
  }
}

obj.cool(); // awesome?
```
这里用到的知识点是我们非常熟悉的词法作用域。self 只是一个可以通过词法作用域和闭包进行引用的标识符，不关心 this 绑定的过程中发生了什么。

ES6 中的箭头函数引人了一个叫作 this 词法的行为：
``` js
var obj = {
  count: 0,
  cool: function coolFn() {
    if (this.count < 1) {
      setTimeout( () => {
        this.count++;
        console.log("awesome?");
      }, 100)
    }
  }
}

obj.cool(); // awesome?
```
箭头函数弃用了所有普通 this 绑定规则，取而代之的是用当前的词法作用域覆盖了 this 本来的值。因此，这个代码片段中的箭头函数只是"继承"了 cool() 函数的 this 绑定。

但是箭头函数的缺点就是因为其是匿名的，上文已介绍过具名函数比匿名函数更可取的原因。而且箭头函数将程序员们经常犯的一个错误给标准化了：混淆了 this 绑定规则和词法作用域规则。

箭头函数不仅仅意味着可以少写代码。本书的作者认为使用 bind() 是更靠得住的方式。
``` js
var obj = {
  count: 0,
  cool: function coolFn() {
    if (this.count < 1) {
      setTimeout( () => {
        this.count++;
        console.log("more awesome");
      }.bind( this ), 100)
    }
  }
}

obj.cool(); // more awesome
```

### 绑定规则
函数在执行的过程中，可以根据下面这4条绑定规则来判断 this 绑定到哪。
* 默认绑定
  * 独立函数调用
* 隐式绑定
  * 当函数引用有上下文对象时，隐式绑定规则会把函数调用中的 this 绑定到这个上下文对象
* 显示绑定
  * call/apply
  * bind（本质是对call/apply函数的封装 `fn.apply( obj, arguments )`）
  * 第三方库的许多函数都提供了一个可选的参数(上下文)，其作用和 bind() 一样，确保回调函数使用指定的 this
* new 绑定
  * JavaScript 中的 new 机制实际上和面向类的语言完全不同
  * 实际上并不存在所谓的“构造函数”，只有对于函数的“构造调用”

书中对4条绑定规则的优先级进行了验证，得出以下的顺序优先级:
* 函数是否在 new 中调用（new 绑定）？如果是的话 this 绑定的是新创建的对象。
* 函数是否通过 call、apply（显式绑定）或者硬绑定（bind）调用？如果是的话，this 绑定的是指定对象。
* 函数是否在某个上下文对象中调用（隐式绑定）？如果是的话，this 绑定的是那个上下文对象。
* 如果都不是的话，使用默认绑定。在严格模式下，绑定到 undefined，否则绑定到全局对象。

### 被忽略的 this
如果你把 null 或者 undefined 作为 this 的绑定对象传入 call、apply 或者 bind，这些值在调用时会被忽略，实际应用的是默认规则。

什么时候会传入 null/undefined 呢？一种非常常见的做法是用 apply(..) 来“展开”一个数组，并当作参数传入一个函数。类似地，bind(..) 可以对参数进行柯里化(预先设置一些参数),如下代码：
``` js
function foo(a, b) {
  console.log( "a:" + a + ", b:" + b );
}

// 把数组"展开"成参数
foo.apply(null, [2, 3]); // a:2, b:3

// 使用 bind(..) 进行柯里化
var bar = foo.bind( null, 2);
bar(3); // a:2, b:3
```
其中 ES6 中，可以用 ... 操作符代替 apply(..) 来“展开”数组，但是 ES6 中没有柯里化的相关语法，因此还是需要使用 bind(..)。

使用 null 来忽略 this 绑定可能产生一些副作用。如果某个函数(比如第三库中的某个函数)确实使用了 this ，默认绑定规则会把 this 绑定到全局对象，这将导致不可预计的后果。更安全的做法是传入一个特殊的对象，一个 “DMZ” 对象，一个空的非委托对象，即 Object.create(null)。
``` js
function foo(a, b) {
  console.log( "a:" + a + ", b:" + b );
}

var ø = Object.create(null);

// 把数组"展开"成参数
foo.apply( ø, [2, 3]); // a:2, b:3

// 使用 bind(..) 进行柯里化
var bar = foo.bind( ø, 2);
bar(3); // a:2, b:3
```

## 对象
JavaScript中的对象有字面形式（比如`var a = { .. }`)和构造形式（比如`var a = new Array(..)`）。字面形式更常用，不过有时候构造形式可以提供更多选择。

作者认为“JavaScript中万物都是对象”的观点是不对的。因为对象只是 6 个基础类型( string、number、boolean、null、undefined、object )之一。对象有包括 function 在内的子对象，不同子类型具有不同的行为，比如内部标签 [object Array] 表示这是对象的子类型数组。

### 复制对象

首先看下这个对象：
```js
let a = {
  name: 'XiaoMing',
  habits:  ['a', 'b']
}
```

从这个对象，先抛出下面几个概念：

* 普通的 = 赋值：b = a，如果修改了 b.name，那么 a.name 也会改变
* 浅复制：如果修改了 b.name, a.name 不会改变，但是修改 b.habits 数组中的值，a.habits 的值也会改变
* 深复制：b 的值改变，不会对 a 产生任何影响

对于 JSON 安全的对象(就是能用 JSON.stringify 序列号的字符串)来说，有一种巧妙的深复制方法：

``` js
var newObj = JSON.parse( JSON.stringify(someObj) )
```

但是这个方法存在以下坑：

1. 如果对象里面有循环引用，会抛错

2. 不能复制对象里面的 Date、Function、RegExp

3. 所有的构造函数会指向 Object

看下面这个对象：
``` js
function anotherFunction() { /*..*/ }

var anotherObject = {
  c: true
};

var anotherArray = [];

var myObject = {
  a: 2,
  b: anotherObject, // 引用，不是复本！
  c: anotherArray, // 另一个引用！
  d: anotherFunction
};

anotherArray.push( myObject )
```
如何准确地表示 myObject 的复制呢？

这个例子中除了复制 myObject 以外还会复制 anotherArray。这时问题就来了，anotherArray 引用了 myObject, 所以又需要复制 myObject，这样就会由于循环引用导致死循环。该如何解决呢？

可以查看在 [diana 库中的实践](https://github.com/MuYunyun/diana/blob/master/src/common/lang/cloneDeep.js)。

相比于深复制，浅复制非常易懂并且问题要少得多，ES6 定义了 Object.assign(..) 方法来实现浅复制。 Object.assign(..) 方法的第一个参数是目标对象，之后还可以跟一个或多个源对象。它会遍历一个或多个源对象的所有可枚举的自由键并把它们复制到目标对象，最后返回目标对象，就像这样：
``` js
var newObj = Object.assign( {}, myObject );

newObj.a; // 2
newObj.b === anotherObject; // true
newObj.c === anotherArray; // true
newObj.d === anotherFunction; // true
```

## 类
JavaScript 有一些近似类的语法元素（比如 new 和 instanceof）, 后来的 ES6 中新增了一些如 class 的关键字。但是 JavaScript 实际上并没有类。类是一种设计模式，JavaScript 的机制其实和类完全不同。
* 类的继承(委托)其实就是复制，但和其他语言中类的表现不同(其他语言类表现出来的都是复制行为)，JavaScript 中的多态（在继承链中不同层次名称相同，但是功能不同的函数）并不表示子类和父类有关联，子类得到的只是父类的一份复本。
* JavaScript 通过显示混入和隐式混入 call() 来模拟其他语言类的表现。此外，显示混入实际上无法完全模拟类的复制行为，因为对象(和函数！别忘了函数也是对象)只能复制引用，无法复制被引用的对象或者函数本身。

### 检查“类”关系
思考下面的代码：
``` js
function Foo() {
  // ...
}

Foo.prototype.blah = ...;

var a = new Foo();
```
我们如何找出 a 的 “祖先”（委托关系）呢？
* 方法一：`a instanceof Foo; // true` (对象 instanceof 函数)
* 方法二: `Foo.prototype.isPrototypeOf(a); // true` (对象 isPrototypeOf 对象)
* 方法三: `Object.getPrototypeOf(a) === Foo.prototype; // true` (Object.getPrototypeOf() 可以获取一个对象的 [[Prototype]]) 链;
* 方法四: `a.__proto__ == Foo.prototype; // true`

### 构造函数

* 函数不是构造函数，而是当且仅当使用 new 时，函数调用会变成“构造函数调用”。
* 使用 new 会在 prototype 生成一个 constructor 属性，指向构造调用的函数。
* constructor 并不表示被构造，而且 constructor 属性并不是一个不可变属性，它是不可枚举的，但它是可以被修改的。

### 对象关联

来看下面的代码：

``` js
var foo = {
  something: function() {
    console.log("Tell me something good...");
  }
};

var bar = Object.create(foo);

bar.something(); // Tell me something good...
```
Object.create(..)会创建一个新对象 (bar) 并把它关联到我们指定的对象 (foo)，这样我们就可以充分发挥 [[Prototype]] 机制的为例（委托）并且避免不必要的麻烦 (比如使用 new 的构造函数调用会生成 .prototype 和 .constructor 引用)。

Object.create(null) 会创建一个拥有空链接的对象，这个对象无法进行委托。由于这个对象没有原型链，所以 instanceof 操作符无法进行判断，因此总是会返回 false 。这些特殊的空对象通常被称作“字典”，它们完全不会受到原型链的干扰，因此非常适合用来存储数据。

我们并不需要类来创建两个对象之间的关系，只需要通过委托来关联对象就足够了。而Object.create(..)不包含任何“类的诡计”，所以它可以完美地创建我们想要的关联关系。

此书的第二章第6部分就把`面对类和继承`和`行为委托`两种设计模式进行了对比，我们可以看到行为委托是一种更加简洁的设计模式，在这种设计模式中能感受到`Object.create()`的强大。

### ES6中的Class
来看一段 ES6中Class 的例子
``` js
class Widget {
  constructor(width, height) {
    this.width = width || 50;
    this.height = height || 50;
    this.$elem = null;
  }
  render($where){
    if (this.$elem) {
      this.$elem.css({
        width: this.width + "px"，
        height: this.height + "px"
      }).appendTo($where);
    }
  }
}

class Button extends Widget {
  constructor(width, height, label) {
    super(width, height);
    this.label = label || "Default";
    this.$elem = $("<button>").text(this.label)
  }
  render($where) {
    super($where);
    this.$elem.click(this.onClick.bind(this));
  }
  onClick(evt) {
    console.log("Button '" + this.label + "' clicked!")
  }
}
```
除了语法更好看之外，ES6还有以下优点
* 基本上不再引用杂乱的 .prototype 了。
* Button 声明时直接 “继承” 了 Widget。
* 可以通过 super(..)来实现相对多态，这样任何方法都可以引用原型链上层的同名方法。
* class 字面语法不能声明属性（只能声明方法）。这是一种限制，但是它会排除掉许多不好的情况。
* 可以通过 extends 很自然地扩展对象(子)类型。

但是 class 就是完美的吗？在传统面向类的语言中，类定义之后就不会进行修改，所以类的设计模式就不支持修改。但JavaScript 最强大的特性之一就是它的动态性，在使用 class 的有些时候还是会用到 .prototype 以及碰到 super (期望动态绑定然而静态绑定) 的问题，class 基本上都没有提供解决方案。

这也是本书作者希望我们思考的问题。