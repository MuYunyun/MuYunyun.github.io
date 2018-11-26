---
title: 原生 JS 实现一个瀑布流插件
copyright: true
tags:
  - JavaScript
  - 瀑布流
  - 轮子
categories:
  - 轮子
abbrlink: 16b9cce7
date: 2018-01-30 00:57:46
---

![](http://with.muyunyun.cn/74f00b858ebdc430e780aa1da6ca0ce1.jpg-muyy)

瀑布流布局中的图片有一个核心特点 —— 等宽不定等高，瀑布流布局在国内外网站都有一定规模的使用，比如[pinterest](https://www.pinterest.com/)、[花瓣网](http://huaban.com/)等等。那么接下来就基于这个特点开始瀑布流探索之旅。

<!-- more -->

### 基础功能实现

首先我们定义好一个有 20 张图片的容器，

```html
<body>
  <style>
    #waterfall {
      position: relative;
    }
    .waterfall-box {
      float: left;
      width: 200px;
    }
  </style>
</body>
<div id="waterfall">
    <img src="images/1.png" class="waterfall-box">
    <img src="images/2.png" class="waterfall-box">
    <img src="images/3.png" class="waterfall-box">
    <img src="images/4.png" class="waterfall-box">
    <img src="images/5.png" class="waterfall-box">
    <img src="images/6.png" class="waterfall-box">
    ...
  </div>
```

![](http://with.muyunyun.cn/88935550542f9cc012151460095d9579.jpg-300)

由于未知的 css 知识点，丝袜最长的妹子把下面的空间都占用掉了。。。

接着正文，假如如上图，每排有 5 列，那第 6 张图片应该出现前 5 张图片哪张的下面呢？当然是绝对定位到前 5 张图片高度最小的图片下方。

那第 7 张图片呢？这时候把第 6 张图片和在它上面的图片当作是一个整体后，思路和上述是一致的。代码实现如下:

```js
Waterfall.prototype.init = function () {
  ...
  const perNum = this.getPerNum() // 获取每排图片数
  const perList = []              // 存储第一列的各图片的高度
  for (let i = 0; i < perNum; i++) {
    perList.push(imgList[i].offsetHeight)
  }

  let pointer = this.getMinPointer(perList) // 求出当前最小高度的数组下标

  for (let i = perNum; i < imgList.length; i++) {
    imgList[i].style.position = 'absolute' // 核心语句
    imgList[i].style.left = `${imgList[pointer].offsetLeft}px`
    imgList[i].style.top = `${perList[pointer]}px`

    perList[pointer] = perList[pointer] + imgList[i].offsetHeight // 数组最小的值加上相应图片的高度
    pointer = this.getMinPointer(perList)
  }
}
```

细心的朋友也许发现了代码中获取图片的高度用到了 `offsetHeight` 这个属性，这个属性的高度之和等于`图片高度 + 内边距 + 边框`，正因为此，我们用了 padding 而不是 margin 来设置图片与图片之间的距离。此外除了`offsetHeight` 属性，此外还要理解 `offsetHeight`、`clientHeight`、`offsetTop`、`scrollTop` 等属性的区别，才能比较好的理解这个项目。css 代码简单如下：
```css
.waterfall-box {
  float: left;
  width: 200px;
  padding-left: 10px;
  padding-bottom: 10px;
}
```

至此完成了瀑布流的基本布局，效果图如下：

![](http://with.muyunyun.cn/74f00b858ebdc430e780aa1da6ca0ce1.jpg-300)

### scroll、resize 事件监听的实现

实现了初始化函数 init 以后，下一步就要实现对 scroll 滚动事件进行监听，从而实现当滚到父节点的底部有源源不断的图片被加载出来的效果。这时候要考虑一个点，是滚动到什么位置时触发加载函数呢？这个因人而异，我的做法是当满足 `父容器高度 + 滚动距离 > 最后一张图片的 offsetTop` 这个条件，即橙色线条 + 紫色线条 > 蓝色线条时触发加载函数，代码如下：

![](http://with.muyunyun.cn/c8cda4bb070a7739eeec0fc968e91a1b.jpg-300)

```js
window.onscroll = function() {
  // ...
  if (scrollPX + bsHeight > imgList[imgList.length - 1].offsetTop) {// 浏览器高度 + 滚动距离 > 最后一张图片的 offsetTop
    const fragment = document.createDocumentFragment()
    for(let i = 0; i < 20; i++) {
      const img = document.createElement('img')
      img.setAttribute('src', `images/${i+1}.png`)
      img.setAttribute('class', 'waterfall-box')
      fragment.appendChild(img)
    }
    $waterfall.appendChild(fragment)
  }
}
```

因为父节点可能自定义节点，所以提供了对监听 scroll 函数的封装，代码如下：
```js
  proto.bind = function () {
    const bindScrollElem = document.getElementById(this.opts.scrollElem)
    util.addEventListener(bindScrollElem || window, 'scroll', scroll.bind(this))
  }

  const util = {
    addEventListener: function (elem, evName, func) {
      elem.addEventListener(evName, func, false)
    },
  }
```

resize 事件的监听与 scroll 事件监听大同小异，当触发了 resize 函数，调用 init 函数进行重置就行。

### 使用发布-订阅模式和继承实现监听绑定

既然以开发插件为目标，不能仅仅满足于功能的实现，还要留出相应的操作空间给开发者自行处理。联想到业务场景中瀑布流中下拉加载的图片一般都来自 Ajax 异步获取，那么加载的数据必然不能写死在库里，期望能实现如下调用(此处借鉴了 [waterfall](https://github.com/mqyqingfeng/waterfall) 的使用方式)，

```js
const waterfall = new Waterfall({options})

waterfall.on("load", function () {
  // 此处进行 ajax 同步/异步添加图片
})
```

观察调用方式，不难联想到使用发布/订阅模式来实现它，关于发布/订阅模式，之前在 [Node.js 异步异闻录](https://github.com/MuYunyun/fe_cloud/issues/7) 有介绍它。其核心思想即通过订阅函数将函数添加到缓存中，然后通过发布函数实现异步调用，下面给出其代码实现:

```js
function eventEmitter() {
  this.sub = {}
}

eventEmitter.prototype.on = function (eventName, func) { // 订阅函数
  if (!this.sub[eventName]) {
    this.sub[eventName] = []
  }
  this.sub[eventName].push(func) // 添加事件监听器
}

eventEmitter.prototype.emit = function (eventName) { // 发布函数
  const argsList = Array.prototype.slice.call(arguments, 1)
  for (let i = 0, length = this.sub[eventName].length; i < length; i++) {
    this.sub[eventName][i].apply(this, argsList) // 调用事件监听器
  }
}
```

接着，要让 Waterfall 能使用发布/订阅模式，只需让 Waterfall 继承 eventEmitter 函数，代码实现如下:

```js
function Waterfall(options = {}) {
  eventEmitter.call(this)
  this.init(options) // 这个 this 是 new 的时候，绑上去的
}

Waterfall.prototype = Object.create(eventEmitter.prototype)
Waterfall.prototype.constructor = Waterfall
```

继承方式的写法吸收了基于构造函数继承和基于原型链继承两种写法的优点，以及使用 `Object.create` 隔离了子类和父类，关于继承更多方面的细节，可以另写一篇文章了，此处点到为止。

### 小优化

为了防止 scroll 事件触发多次加载图片，可以考虑用函数防抖与节流实现。在基于发布-订阅模式的基础上，定义了个 isLoading 参数表示是否在加载中，并根据其布尔值决定是否加载，代码如下：

```js
let isLoading = false
const scroll = function () {
  if (isLoading) return false // 避免一次触发事件多次
  if (scrollPX + bsHeight > imgList[imgList.length - 1].offsetTop) { // 浏览器高度 + 滚动距离 > 最后一张图片的 offsetTop
    isLoading = true
    this.emit('load')
  }
}

proto.done = function () {
  this.on('done', function () {
    isLoading = false
    ...
  })
  this.emit('done')
}
```

这时候需要在调用的地方加上 `waterfall.done`, 从而告知当前图片已经加载完毕，代码如下:

```js
const waterfall = new Waterfall({})
waterfall.on("load", function () {
  // 异步/同步加载图片
  waterfall.done()
})
```

### 项目地址

[项目地址](https://github.com/MuYunyun/waterfall)

[此插件在 React 项目中的运用](https://github.com/MuYunyun/reactSPA/blob/master/src/common/pages/waterfall/index.js)

项目简陋，不足之处在所难免，欢迎留下你们宝贵的意见。





