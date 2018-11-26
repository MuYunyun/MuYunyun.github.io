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

![](http://with.muyunyun.cn/9c461a61924ed0fecb6024a256671251.jpg-muyy)

本系列文章在实现一个 cpreact 的同时帮助大家理顺 React 框架的核心内容(JSX/虚拟DOM/组件/生命周期/diff算法/setState/PureComponent/HOC/...) [项目地址](https://github.com/MuYunyun/cpreact)

<!--more-->

* [从 0 到 1 实现 React 系列 —— JSX 和 Virtual DOM](https://github.com/MuYunyun/blog/issues/24)
* [从 0 到 1 实现 React 系列 —— 组件和 state|props](https://github.com/MuYunyun/blog/issues/25)
* [从 0 到 1 实现 React 系列 —— 生命周期和 diff 算法](https://github.com/MuYunyun/blog/issues/26)
* [从 0 到 1 实现 React 系列 —— 优化 setState 和 ref 的实现](https://github.com/MuYunyun/blog/issues/27)
* [从 0 到 1 实现 React 系列 —— PureComponent 实现 && HOC 探幽](https://github.com/MuYunyun/blog/issues/29)

### 环境准备

项目打包工具选择了 parcel，使用其可以快速地进入项目开发的状态。[快速开始](https://parceljs.org/getting_started.html)

此外需要安装以下 babel 插件：

```js
"@babel/core": "^7.0.0",
"@babel/preset-env": "^7.0.0",
"@babel/preset-react": "^7.0.0",
"babel-loader": "v8.0.0-beta.0",
```

同时 `.babelrc` 配置如下：

```js
{
	"presets": [
		[
			"@babel/preset-env",
			{
				"targets": "> 0.25%, not dead",
				"useBuiltIns": "entry"
			}
		],
		[
			"@babel/preset-react", {
				"pragma": "cpreact.createElement" // 该参数传向 transform-react-jsx 插件，是前置的一个核心，后文有解释为什么使用 cpreact.createElement
			}
		]
	]
}
```


配置好 babel 后，接着提供两套打包工具的配置方案，读者可以自行选择。

#### 方案 1：使用 webpack

webpack 拥有一个活跃的社区，提供了更为丰富的打包能力。

首先安装以下模块：

```
"webpack": "^4.17.2",
"webpack-cli": "^3.1.0",
"webpack-dev-server": "^3.1.8"
```

在根目录的 `webpack.config.js` 配置如下：

```js
const webpack = require('webpack')
const path = require('path')
const rootPath = path.resolve(__dirname)

module.exports = {
  entry: path.resolve(rootPath, 'test', 'index.js'),
  mode: 'development',
  devtool: 'inline-source-map',
  devServer: {
    contentBase: './dist'
  },
  output: {
    filename: 'cpreact.js',
    path: path.resolve(rootPath, 'dist'),
    libraryTarget: 'umd'
  },
  module: {
    rules: [{
      test: /\.js$/,
      loader: "babel-loader",
    }]
  },
}
```

然后在 `package.json` 里加上如下配置：

```
"scripts": {
  "start": "webpack-dev-server --open",
},
```

具体可以参照 [0.4.3 版本](https://github.com/MuYunyun/cpreact/blob/master/webpack.config.js)

#### 方案 2：使用 parcel

[parcel](https://parceljs.org/getting_started.html) 是一款上手极快的打包工具，使用其可以快速地进入项目开发的状态。在 `package.json` 加上如下配置，具体可以参照 [0.1 版本](https://github.com/MuYunyun/cpreact/blob/0.1/package.json)

```
"scripts": {
  "start": "parcel ./index.html --open -p 8080 --no-cache"
},
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

![](http://with.muyunyun.cn/a898514bd3d08df4366e5ceb7843cddf.jpg-400)

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

![](http://with.muyunyun.cn/5e451855ccc9017708b57164f9e221c6.jpg-400)

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

### 鸣谢
Especially thank [simple-react](https://github.com/hujiulong/simple-react) for the guidance function of this library. At the meantime，respect for [preact](https://github.com/developit/preact) and [react](https://github.com/facebook/react)