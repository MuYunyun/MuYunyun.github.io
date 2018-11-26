---
title: 从 0 到 1 实现 React 系列 —— 2.组件和 state|props
copyright: true
tags:
  - React
categories:
  - React
abbrlink: a40f0b93
date: 2018-07-12 10:03:17
---

![](http://with.muyunyun.cn/9c461a61924ed0fecb6024a256671251.jpg-muyy)

本系列文章在实现一个 cpreact 的同时帮助大家理顺 React 框架的核心内容(JSX/虚拟DOM/组件/生命周期/diff算法/setState/PureComponent/HOC/...) [项目地址](https://github.com/MuYunyun/cpreact)

<!--more-->

* [从 0 到 1 实现 React 系列 —— JSX 和 Virtual DOM](https://github.com/MuYunyun/blog/issues/24)
* [从 0 到 1 实现 React 系列 —— 组件和 state|props](https://github.com/MuYunyun/blog/issues/25)
* [从 0 到 1 实现 React 系列 —— 生命周期和 diff 算法](https://github.com/MuYunyun/blog/issues/26)
* [从 0 到 1 实现 React 系列 —— 优化 setState 和 ref 的实现](https://github.com/MuYunyun/blog/issues/27)
* [从 0 到 1 实现 React 系列 —— PureComponent 实现 && HOC 探幽](https://github.com/MuYunyun/blog/issues/29)

### 组件即函数

在上一篇 [JSX 和 Virtual DOM](https://github.com/MuYunyun/blog/issues/24) 中，解释了 JSX 渲染到界面的过程并实现了相应代码，代码调用如下所示：

```js
import React from 'react'
import ReactDOM from 'react-dom'

const element = (
  <div className="title">
    hello<span className="content">world!</span>
  </div>
)

ReactDOM.render(
  element,
  document.getElementById('root')
)
```

本小节，我们接着探究组件渲染到界面的过程。在此我们引入组件的概念，`组件本质上就是一个函数`，如下就是一段标准组件代码：

```jsx
import React from 'react'

// 写法 1：
class A {
  render() {
    return <div>I'm componentA</div>
  }
}

// 写法 2：无状态组件
const A = () => <div>I'm componentA</div>

ReactDOM.render(<A />, document.body)
```

`<A name="componentA" />` 是 JSX 的写法，和[上一篇](https://github.com/MuYunyun/blog/issues/24)同理，babel 将其转化为 React.createElement() 的形式，[转化结果](https://babeljs.io/en/repl#?babili=false&browsers=&build=&builtIns=false&spec=false&loose=false&code_lz=MYGwhgzhAECC0FMAeAXBA7AJjAwgewFsAHPdDFaAbwCgBIAJw0wXoAoBKKuhhFAV3rpoAHkwBLAG4A-AJIByAlRQALMRAB0ReniIb0YAggC-wgPTjpAbjpHqt6sPj7DAXgBEwQiTLoUsN9CmUtRAA&debug=false&forceAllTransforms=false&shippedProposals=false&circleciRepo=&evaluate=false&fileSize=false&sourceType=module&lineWrap=true&presets=react&prettier=false&targets=&version=6.26.0&envVersion=)如下所示：

```js
React.createElement(A, null)
```

可以看到当 JSX 中是自定义组件的时候，createElement 后接的第一个参数变为了函数，在 [repl](https://preactjs.com/repl) 打印 `<A name="componentA" />`，结果如下：

```
{
  attributes: undefined,
  children: [],
  key: undefined,
  nodeName: ƒ A()
}
```

注意这时返回的 Virtual DOM 中的 nodeName 也变为了函数。根据这些线索，我们对之前的 `render` 函数进行改造。

```js
function render(vdom, container) {
  if (_.isFunction(vdom.nodeName)) { // 如果 JSX 中是自定义组件
    let component, returnVdom
    if (vdom.nodeName.prototype.render) {
      component = new vdom.nodeName()
      returnVdom = component.render()
    } else {
      returnVdom = vdom.nodeName() // 针对无状态组件：const A = () => <div>I'm componentsA</div>
    }
    render(returnVdom, container)
    return
  }
}
```

至此，我们完成了对组件的处理逻辑。

### props 和 state 的实现

在上个小节组件 A 中，是没有引入任何属性和状态的，我们希望组件间能进行属性的传递(props)以及组件内能进行状态的记录(state)。

```jsx
import React, { Component } from 'react'

class A extends Component {
  render() {
    return <div>I'm {this.props.name}</div>
  }
}

ReactDOM.render(<A name="componentA" />, document.body)
```

在上面这段代码中，看到 A 函数继承自 Component。我们来构造这个父类 Component，并在其添加 state、props、setState 等属性方法，从而让子类继承到它们。

```js
function Component(props) {
  this.props = props
  this.state = this.state || {}
}
```

首先，我们将组件外的 props 传进组件内，修改 render 函数中以下代码：

```js
function render(vdom, container) {
  if (_.isFunction(vdom.nodeName)) {
    let component, returnVdom
    if (vdom.nodeName.prototype.render) {
      component = new vdom.nodeName(vdom.attributes) // 将组件外的 props 传进组件内
      returnVdom = component.render()
    } else {
      returnVdom = vdom.nodeName(vdom.attributes) 	// 处理无状态组件：const A = (props) => <div>I'm {props.name}</div>
    }
    ...
  }
  ...
}
```

实现完组件间 props 的传递后，再来聊聊 state，在 react 中是通过 setState 来完成组件状态的改变的，后续章节会对这个 api（异步）深入探究，这里简单实现如下：

```js
function Component(props) {
  this.props = props
  this.state = this.state || {}
}

Component.prototype.setState = function() {
  this.state = Object.assign({}, this.state, updateObj) // 这里简单实现，后续篇章会深入探究
  const returnVdom = this.render() // 重新渲染
  document.getElementById('root').innerHTML = null
  render(returnVdom, document.getElementById('root'))
}
```

此时虽然已经实现了 setState 的功能，但是 `document.getElementById('root')` 节点写死在 setState 中显然不是我们希望的，我们将 dom 节点相关转移到 _render 函数中：

```js
Component.prototype.setState = function(updateObj) {
  this.state = Object.assign({}, this.state, updateObj)
  _render(this) // 重新渲染
}
```

自然地，重构与之相关的 render 函数：

```js
function render(vdom, container) {
  let component
  if (_.isFunction(vdom.nodeName)) {
    if (vdom.nodeName.prototype.render) {
      component = new vdom.nodeName(vdom.attributes)
    } else {
      component = vdom.nodeName(vdom.attributes) // 处理无状态组件：const A = (props) => <div>I'm {props.name}</div>
    }
  }
  component ? _render(component, container) : _render(vdom, container)
}
```

在 render 函数中分离出 _render 函数的目的是为了让 setState 函数中也能调用 _render 逻辑。完整 _render 函数如下：

```js
function _render(component, container) {
  const vdom = component.render ? component.render() : component
  if (_.isString(vdom) || _.isNumber(vdom)) {
    container.innerText = container.innerText + vdom
    return
  }
  const dom = document.createElement(vdom.nodeName)
  for (let attr in vdom.attributes) {
    setAttribute(dom, attr, vdom.attributes[attr])
  }
  vdom.children.forEach(vdomChild => render(vdomChild, dom))
  if (component.container) {  // 注意：调用 setState 方法时是进入这段逻辑，从而实现我们将 dom 的逻辑与 setState 函数分离的目标；知识点: new 出来的同一个实例
    component.container.innerHTML = null
    component.container.appendChild(dom)
    return
  }
  component.container = container
  container.appendChild(dom)
}
```

让我们用下面这个用例跑下写好的 react 吧！

```js
class A extends Component {
  constructor(props) {
    super(props)
    this.state = {
      count: 1
    }
  }

  click() {
    this.setState({
      count: ++this.state.count
    })
  }

  render() {
    return (
      <div>
        <button onClick={this.click.bind(this)}>Click Me!</button>
        <div>{this.props.name}:{this.state.count}</div>
      </div>
    )
  }
}

ReactDOM.render(
  <A name="count" />,
  document.getElementById('root')
)
```

效果图如下：

![](http://with.muyunyun.cn/reactsetstate.gif)

至此，我们实现了 props 和 state 部分的逻辑。

### forceUpdate 的实现

> 声明：这部分为补充章节，可以选择性阅读。涉及到后文[生命周期](https://github.com/MuYunyun/blog/blob/master/BasicSkill/从0到1实现React/3.生命周期.md)、[setState](https://github.com/MuYunyun/blog/blob/master/BasicSkill/从0到1实现React/5.setState.md) 章节的知识点。

当没有使用 setState 更新 state 状态时，通常要结合 forceUpdate 一起使用，例子如下：

```js
class B extends Component {
  constructor(props) {
    super(props)
    this.state = {
      count: {
        value: 1
      }
    }
  }

  shouldComponentUpdate() { // 当使用 forceUpdate() 时，shouldComponentUpdate() 会失效
    return false
  }

  click() {
    this.state.count.value = ++this.state.count.value // 没有使用 setState 更新 state 状态时，通常要结合 forceUpdate 一起使用
    this.forceUpdate()
  }

  render() {
    return (
      <div>
        <button onClick={this.click.bind(this)}>Click Me!</button>
        <div>{this.state.count.value}</div>
      </div>
    )
  }
}
```

这里要注意一个点`当使用 forceUpdate() 时，shouldComponentUpdate() 会失效`，下面我们来补充 forceUpdate() 的代码逻辑：

```js
// force to update
Component.prototype.forceUpdate = function(cb) {
  this.allowShouldComponentUpdate = false // 不允许 allowShouldComponentUpdate 执行
  asyncRender({}, this, cb)
}
```

相应的在 render.js 中加上 allowShouldComponentUpdate 的判断条件：

```js
function renderComponent(component) {
  if (component.base && component.shouldComponentUpdate && component.allowShouldComponentUpdate !== false) { // 加上 allowShouldComponentUpdate 的判断条件
    const bool = component.shouldComponentUpdate(component.props, component.state)
    if (!bool && bool !== undefined) {
      return false // shouldComponentUpdate() 返回 false，则生命周期终止
    }
  }
  ...
}
```

### 小结

组件即函数；当 JSX 中是自定义组件时，经过 babel 转化后的 React.createElement(fn, ..) 后中的第一个参数变为了函数，除此之外其它逻辑与 JSX 中为 html 元素的时候相同；

此外我们将 state/props/setState 等 api 封装进了父类 React.Component 中，从而在子类中能调用这些属性和方法。

在下篇，我们会继续实现生命周期机制，如有疏漏，欢迎斧正。

### 鸣谢
Especially thank [simple-react](https://github.com/hujiulong/simple-react) for the guidance function of this library. At the meantime，respect for [preact](https://github.com/developit/preact) and [react](https://github.com/facebook/react)