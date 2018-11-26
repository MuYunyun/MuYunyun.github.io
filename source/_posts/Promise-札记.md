---
title: JS 异步系列 —— Promise 札记
copyright: true
tags:
  - Promise
categories:
  - Promise
abbrlink: 690a449f
date: 2018-07-02 12:09:57
---

![](http://with.muyunyun.cn/60f4b6024c6dd00425a7fdc9f8067254.jpg-muyy)

实践了一个符合 Promise/A+ 规范的 [repromise](https://github.com/MuYunyun/repromise)

<!--more-->

### Promise 札记

研究 Promise 的动机大体有以下几点：

* 对其 api 的不熟悉以及对实现机制的好奇;

* 很多库(比如 fetch)是基于 Promise 封装的，那么要了解这些库的前置条件得先熟悉 Promise;

* 要了解其它更为高级的异步操作得先熟悉 Promise;

基于这些目的，实践了一个符合 Promise/A+ 规范的 [repromise](https://github.com/MuYunyun/repromise)

本札记系列总共三篇文章，作为之前的文章 [Node.js 异步异闻录](https://github.com/MuYunyun/blog/issues/7) 的拆分和矫正。

* [Promise札记](https://github.com/MuYunyun/blog/blob/master/BasicSkill/readES6/Promise札记.md)
* [Generator札记](https://github.com/MuYunyun/blog/blob/master/BasicSkill/readES6/Generator札记.md)
* [Async札记](https://github.com/MuYunyun/blog/blob/master/BasicSkill/readES6/Async札记.md)

### Promise/A+ 核心

![](http://with.muyunyun.cn/e1a0c15c44f9b014aa78d7b7620db474.jpg-200)

在实现一个符合 Promise/A+ 规范的 promise 之前，先了解下 Promise/A+ 核心，想更全面地了解可以阅读 [Promise/A+规范](https://segmentfault.com/a/1190000002452115)

* Promise 操作只会处在 3 种状态的一种：未完成态(pending)、完成态(resolved) 和失败态(rejected);
* Promise 的状态只会出现从未完成态向完成态或失败态转化;
* Promise 的状态一旦转化，将不能被更改;

### repromise api 食用手册

#### Promise.resolve()

Promise.resolve() 括号内有 4 种情况

```js
/* 跟 Promise 对象 */
Promise.resolve(Promise.resolve(1))
// Promise {state: "resolved", data: 1, callbackQueue: Array(0)}

/* 跟 thenable 对象 */
var thenable = {
  then: function(resolve, reject) {
    resolve(1)
  }
}

Promise.resolve(thenable)
// Promise {state: "resolved", data: 1, callbackQueue: Array(0)}

/* 普通参数 */
Promise.resolve(1)
// Promise {state: "resolved", data: 1, callbackQueue: Array(0)}

/* 不跟参数 */
Promise.resolve()
// Promise {state: "resolved", data: undefined, callbackQueue: Array(0)}
```

#### Promise.reject()

相较于 Promise.resolve()，Promise.reject() 原封不动地返回参数值

#### Promise.all(arr)

对于 Promise.all(arr) 来说，在参数数组中所有元素都变为决定态后，然后才返回新的 promise。

```js
// 以下 demo，请求两个 url，当两个异步请求返还结果后，再请求第三个 url
const p1 = request(`http://some.url.1`)
const p2 = request(`http://some.url.2`)

Promise.all([p1, p2])
  .then((datas) => { // 此处 datas 为调用 p1, p2 后的结果的数组
    return request(`http://some.url.3?a=${datas[0]}&b=${datas[1]}`)
  })
  .then((data) => {
    console.log(msg)
  })
```

#### Promise.race(arr)

对于 Promise.race(arr) 来说，只要参数数组有一个元素变为决定态，便返回新的 promise。

```js
// race 译为竞争，同样是请求两个 url，当且仅当一个请求返还结果后，就请求第三个 url
const p1 = request(`http://some.url.1`)
const p2 = request(`http://some.url.2`)

Promise.race([p1, p2])
  .then((data) => { // 此处 data 取调用 p1, p2 后优先返回的结果
    return request(`http://some.url.3?value=${data}`)
  })
  .then((data) => {
    console.log(data)
  })
```

#### Promise.wrap(fn) —— 回调函数转 Promise

通过下面这个案例，提供回调函数 Promise 化的思路。

```js
function foo(a, b, cb) {
  ajax(
    `http://some.url?a=${a}&b=${b}`,
    cb
  )
}

foo(1, 2, function(err, data) {
  if (err) {
    console.log(err)
  } else {
    console.log(data)
  }
})
```

如上是一个传统回调函数使用案例，只要使用 Promise.wrap() 包裹 foo 函数就对其完成了 promise 化，使用如下：

```js
const promiseFoo = Promise.wrap(foo)

promiseFoo(1, 2)
  .then((data) => {
    console.log(data)
  })
  .catch((err) => {
    console.log(err)
  })
```

Promise.wrap 的实现逻辑也顺带列出来了：

```js
Promise.wrap = function(fn) {
  return funtion() {
    const args = [].slice.call(arguments)
    return new Promise((resolve, reject) => {
      fn.apply(null, args.concat((err, data) => {
        if (err) {
          reject(err)
        } else {
          resolve(data)
        }
      }))
    })
  }
}
```

#### then/catch/done

这几个 api 比较简单，合起来一起带过

```js
Promise.resolve(1)
  .then((data) => {console.log(data)}, (err) => {console.log(err)}) // 链式调用，可以传一个参数(推荐)，也可以传两个参数
  .catch((err) => {console.log(err)}) // 捕获链式调用中抛出的错误 || 捕获变为失败态的值
  .done()                             // 能捕获前面链式调用的错误(包括 catch 中)，可以传两个参数也可不传
```

### 实践过程总结

#### 坑点 1：事件循环

> 事件循环：同步队列执行完后，在指定时间后再执行异步队列的内容。

之所以要单列事件循环，因为代码的执行顺序与其息息相关，此处用 setTimeout 来模拟事件循环；

下面代码片段中，① 处执行完并不会马上执行 setTimeout() 中的代码(③)，而是此时有多少次 then 的调用，就会重新进入 ② 处多少次后，再进入 ③

```js
excuteAsyncCallback(callback, value) {
  const that = this
  setTimeout(function() {
    const res = callback(value) // ③
    that.excuteCallback('fulfilled', res)
  }, 4)
}

then(onResolved, onRejected) {
  const promise = new this.constructor()
  if (this.state !== 'PENDING') {
    const callback = this.state === 'fulfilled' ? onResolved : onRejected
    this.excuteAsyncCallback.call(promise, callback, this.data)              // ①
  } else {
    this.callbackArr.push(new CallbackItem(promise, onResolved, onRejected)) // ②
  }
  return promise
}
```

#### 坑点 2：this 的指向问题

this.callbackArr.push() 中的 this 指向的是 ‘上一个’ promise，所以类 CallbackItem 中，this.promise 存储的是'下一个' promise(then 对象)。

```js
class Promise {
  ...
  then(onResolved, onRejected) {
    const promise = new this.constructor()
    if (this.state !== 'PENDING') {        // 第一次进入 then，状态是 RESOLVED 或者是 REJECTED
      const callback = this.state === 'fulfilled' ? onResolved : onRejected
      this.excuteAsyncCallback.call(promise, callback, this.data)  // 绑定 this 到 promise
    } else {                               // 从第二次开始以后，进入 then，状态是 PENDING
      this.callbackArr.push(new CallbackItem(promise, onResolved, onRejected)) // 这里的 this 也是指向‘上一个’ promise
    }
    return promise
  }
  ...
}

class CallbackItem {
  constructor(promise, onResolve, onReject) {
    this.promise = promise // 相应地，这里存储的 promise 是来自下一个 then 的
    this.onResolve = typeof(onResolve) === 'function' ? onResolve : (resolve) => {}
    this.onReject = typeof(onRejected) === 'function' ? onRejected : (rejected) => {}
  }
  ...
}
```

### more

实践的更多过程可以参考[测试用例](https://github.com/MuYunyun/repromise/tree/master/test)。有好的意见欢迎交流。