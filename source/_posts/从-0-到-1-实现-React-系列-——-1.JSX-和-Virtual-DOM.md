---
title: 从 0 到 1 实现 React 系列 —— 1.JSX 和 Virtual DOM
copyright: true
tags:
  - React
categories:
  - React
abbrlink: e9e32d3a
date: 2018-07-06 16:01:10
---

![](http://oqhtscus0.bkt.clouddn.com/9c461a61924ed0fecb6024a256671251.jpg-muyy)

看源码一个痛处是会陷进理不顺主干的困局中，本系列文章在实现一个 (x)react 的同时理顺 React 框架的主干内容(JSX/虚拟DOM/组件/生命周期/diff算法/setState/ref/...)

<!--more-->

* [从 0 到 1 实现 React 系列 —— JSX 和 Virtual DOM](https://github.com/MuYunyun/blog/issues/24)
* [从 0 到 1 实现 React 系列 —— 组件和 state|props](https://github.com/MuYunyun/blog/issues/25)
* [从 0 到 1 实现 React 系列 —— 生命周期和 diff 算法](https://github.com/MuYunyun/blog/issues/26)
* [从 0 到 1 实现 React 系列 —— 优化 setState 和 ref 的实现](https://github.com/MuYunyun/blog/issues/27)

### 环境准备

项目打包工具选择了 parcel，使用其可以快速地进入项目开发的状态。[快速开始](https://parceljs.org/getting_started.html)

此外需要安装以下 babel 插件：

```js
"babel-core": "^6.26.0",
"babel-preset-env": "^1.6.1",
"babel-plugin-transform-react-jsx": "^6.24.1"
```

同时 `.babelrc` 配置如下：

```js
{
    "presets": ["env"],
    "plugins": [
        // 插件如其名：转化 JSX 语法为定义的形式
        ["transform-react-jsx", {
            "pragma": "React.createElement"
        }]
    ]
}
```

### JSX 和 虚拟 DOM

```js
const element = (
  <div className="title">
    hello<span className="content">world!</span>
  </div>
)
```

JSX 是一种语法糖，经过 [babel](https://babeljs.io/en/repl) 转换结果如下，可以发现实际上转化成 `React.createElement()` 的形式：

```js
var element = React.createElement(
  "div",
  { className: "title" },
  "hello",
  React.createElement(
    "span",
    { className: "content" },
    "world!"
  )
);
```

[打印](https://preactjs.com/repl) element, 结果如下：

```js
{
  attributes: {className: "title"}
  children: ["hello", t] // t 和外层对象相同
  key: undefined
  nodeName: "div"
}
```

因此，我们得出结论：JSX 语法糖经过 Babel 编译后转换成一种对象，该对象即所谓的`虚拟 DOM`，使用虚拟 DOM 能让页面进行更为高效的渲染。

我们按照这种思路进行函数的构造：

```js
const React = {
  createElement
}

function createElement(tag, attr, ...child) {
  return {
    attributes: attr,
    children: child,
    key: undefined,
    nodeName: tag,
  }
}

// 测试
const element = (
  <div className="title">
    hello<span className="content">world!</span>
  </div>
)

console.log(element) // 打印结果符合预期
// {
//   attributes: {className: "title"}
//   children: ["hello", t] // t 和外层对象相同
//   key: undefined
//   nodeName: "div"
// }
```

### 虚拟 DOM 转化为真实 DOM

上个小节介绍了 JSX 转化为虚拟 DOM 的过程，这个小节接着来实现将虚拟 DOM 转化为真实 DOM (页面上渲染的是真实 DOM)。

我们知道在 React 中，将虚拟 DOM 转化为真实 DOM 是使用 `ReactDOM.render` 实现的，使用如下：

```js
import ReactDOM from 'react-dom'

ReactDOM.render(
  element, // 上文的 element，即虚拟 dom
  document.getElementById('root')
)
```

接着来实现 `ReactDOM.render` 的逻辑:

```js
const ReactDOM = {
  render
}

/**
 * 将虚拟 DOM 转化为真实 DOM
 * @param {*} vdom      虚拟 DOM
 * @param {*} container 需要插入的位置
 */
function render(vdom, container) {
  if (_.isString(vdom) || _.isNumber(vdom)) {
    container.innerText = container.innerText + vdom // fix <div>I'm {this.props.name}</div>
    return
  }
  const dom = document.createElement(vdom.nodeName)
  for (let attr in vdom.attributes) {
    setAttribute(dom, attr, vdom.attributes[attr])
  }
  vdom.children.forEach(vdomChild => render(vdomChild, dom))
  container.appendChild(dom)
}

/**
 * 给节点设置属性
 * @param {*} dom   操作元素
 * @param {*} attr  操作元素属性
 * @param {*} value 操作元素值
 */
function setAttribute(dom, attr, value) {
  if (attr === 'className') {
    attr = 'class'
  }
  if (attr.match('/on\w+/')) {   // 处理事件的属性:
    const eventName = attr.toLowerCase().substr(2)
    dom.addEventListener(eventName, value)
  } else if (attr === 'style') { // 处理样式的属性:
    let styleStr = ''
    let standardCss
    for (let klass in value) {
      standardCss = humpToStandard(klass) // 处理驼峰样式为标准样式
      value[klass] = _.isNumber(+value[klass]) ? value[klass] + 'px' : value[klass] // style={{ className: '20' || '20px' }}>
      styleStr += `${standardCss}: ${value[klass]};`
    }
    dom.setAttribute(attr, styleStr)
  } else {                       // 其它属性
    dom.setAttribute(attr, value)
  }
}
```

至此，我们成功将虚拟 DOM 复原为真实 DOM，展示如下：

![](http://oqhtscus0.bkt.clouddn.com/a898514bd3d08df4366e5ceb7843cddf.jpg-400)

另外配合热更新，在热更新的时候清空之前的 dom 元素，改动如下：

```js
const ReactDOM = {
  render(vdom, container) {
    container.innerHTML = null
    render(vdom, container)
  }
}
```

### 小结

`JSX` 经过 babel 编译为 React.createElement() 的形式，其返回结果就是 `Virtual DOM`，最后通过 ReactDOM.render() 将 Virtual DOM 转化为真实的 DOM 展现在界面上。流程图如下：

![](http://oqhtscus0.bkt.clouddn.com/5e451855ccc9017708b57164f9e221c6.jpg-400)

### 思考题

如下是一个 react/preact 的常用组件的写法，那么为什么要 import 一个 React 或者 h 呢？

```jsx
import React, { Component } from 'react' // react
// import { h, Component } from 'preact' // preact

class A extends Component {
  render() {
    return <div>I'm componentA</div>
  }
}

render(<A />, document.body) // 组件的挂载
```

### 项目说明

该系列文章会尽可能的分析项目细节，具体的还是以项目实际代码为准。

[项目地址](https://github.com/MuYunyun/cpreact)，[关于如何 pr](https://github.com/MuYunyun/cpreact/blob/master/.github/PULL_REQUEST_TEMPLATE.md)

本系列文章拜读和借鉴了 [simple-react](https://github.com/hujiulong/simple-react)，在此特别感谢 [Jiulong Hu](https://github.com/hujiulong) 的分享。