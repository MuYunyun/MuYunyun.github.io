---
title: 从 0 到 1 实现 React 系列 —— 4.setState优化和ref的实现
copyright: true
tags:
  - React
categories:
  - React
abbrlink: 55ccbd9e
date: 2018-08-05 22:22:32
---

![](http://with.muyunyun.cn/9c461a61924ed0fecb6024a256671251.jpg-muyy)

本系列文章在实现一个 cpreact 的同时帮助大家理顺 React 框架的核心内容(JSX/虚拟DOM/组件/生命周期/diff算法/setState/PureComponent/HOC/...) [项目地址](https://github.com/MuYunyun/cpreact)

<!--more-->

* [从 0 到 1 实现 React 系列 —— JSX 和 Virtual DOM](https://github.com/MuYunyun/blog/issues/24)
* [从 0 到 1 实现 React 系列 —— 组件和 state|props](https://github.com/MuYunyun/blog/issues/25)
* [从 0 到 1 实现 React 系列 —— 生命周期和 diff 算法](https://github.com/MuYunyun/blog/issues/26)
* [从 0 到 1 实现 React 系列 —— 优化 setState 和 ref 的实现](https://github.com/MuYunyun/blog/issues/27)
* [从 0 到 1 实现 React 系列 —— PureComponent 实现 && HOC 探幽](https://github.com/MuYunyun/blog/issues/29)

### 同步 setState 的问题

而在现有 setState 逻辑实现中，每调用一次 setState 就会执行 render 一次。因此在如下代码中，每次点击增加按钮，因为 click 方法里调用了 10 次 setState 函数，页面也会被渲染 10 次。而我们希望的是每点击一次增加按钮只执行 render 函数一次。

```js
export default class B extends Component {
  constructor(props) {
    super(props)
    this.state = {
      count: 0
    }
    this.click = this.click.bind(this)
  }

  click() {
    for (let i = 0; i < 10; i++) {
      this.setState({ // 在先前的逻辑中，没调用一次 setState 就会 render 一次
        count: ++this.state.count
      })
    }
  }

  render() {
    console.log(this.state.count)
    return (
      <div>
        <button onClick={this.click}>增加</button>
        <div>{this.state.count}</div>
      </div>
    )
  }
}
```

### 异步调用 setState

查阅 setState 的 api，其形式如下：

```js
setState(updater, [callback])
```

它能接收两个参数，其中第一个参数 updater 可以为对象或者为函数 (`(prevState, props) => stateChange`)，第二个参数为回调函数；

确定优化思路为：将多次 setState 后跟着的值进行浅合并，并借助事件循环等所有值合并好之后再进行渲染界面。

```js
let componentArr = []

// 异步渲染
function asyncRender(updater, component, cb) {
  if (componentArr.length === 0) {
    defer(() => render())       // 利用事件循环，延迟渲染函数的调用
  }

  if (cb) defer(cb)             // 调用回调函数
  if (_.isFunction(updater)) {  // 处理 setState 后跟函数的情况
    updater = updater(component.state, component.props)
  }
  // 浅合并逻辑
  component.state = Object.assign({}, component.state, updater)
  if (componentArr.includes(component)) {
    component.state = Object.assign({}, component.state, updater)
  } else {
    componentArr.push(component)
  }
}

function render() {
  let component
  while (component = componentArr.shift()) {
    renderComponent(component) // rerender
  }
}

// 事件循环，关于 promise 的事件循环和 setTimeout 的事件循环后续会单独写篇文章。
const defer = function(fn) {
  return Promise.resolve().then(() => fn())
}
```

此时，每点击一次增加按钮 render 函数只执行一次了。

### ref 的实现

在 react 中并不建议使用 ref 属性，而应该尽量使用[状态提升](https://doc.react-china.org/docs/lifting-state-up.html)，但是 react 还是提供了 ref 属性赋予了开发者操作 dom 的能力，react 的 ref 有 `string`、`callback`、`createRef` 三种形式，分别如下：

```js
// string 这种写法未来会被抛弃
class MyComponent extends Component {
  componentDidMount() {
    this.refs.myRef.focus()
  }
  render() {
    return <input ref="myRef" />
  }
}

// callback(比较通用)
class MyComponent extends Component {
  componentDidMount() {
    this.myRef.focus()
  }
  render() {
    return <input ref={(ele) => {
      this.myRef = ele
    }} />
  }
}

// react 16.3 增加，其它 react-like 框架还没有同步
class MyComponent extends Component {
  constructor() {
    super() {
      this.myRef = React.createRef()
    }
  }
  componentDidMount() {
    this.myRef.current.focus()
  }
  render() {
    return <input ref={this.myRef} />
  }
}
```

[React ref 的前世今生](https://zhuanlan.zhihu.com/p/40462264) 罗列了三种写法的差异，下面对上述例子中的第二种写法(比较通用)进行实现。

首先在 setAttribute 方法内补充上对 ref 的属性进行特殊处理，

```js
function setAttribute(dom, attr, value) {
  ...
  else if (attr === 'ref') {          // 处理 ref 属性
    if (_.isFunction(value)) {
      value(dom)
    }
  }
  ...
}
```

针对这个例子中 `this.myRef.focus()` 的 focus 属性需要异步处理，因为调用 componentDidMount 的时候，界面上还未添加 dom 元素。处理 renderComponent 函数：

```js
function renderComponent(component) {
  ...
  else if (component && component.componentDidMount) {
    defer(component.componentDidMount.bind(component))
  }
  ...
}
```

刷新页面，可以发现 input 框已为选中状态。

![](http://with.muyunyun.cn/d35589fbbff45a2437c6c13e24ba8058.jpg-200)

处理完普通元素的 ref 后，再来处理下自定义组件的 ref 的情况。之前默认自定义组件上是没属性的，现在只要针对自定义组件的 ref 属性做相应处理即可。稍微修改 vdomToDom 函数如下：

```js
function vdomToDom(vdom) {
  if (_.isFunction(vdom.nodeName)) { // 此时是自定义组件
    ...
    for (const attr in vdom.attributes) { // 处理自定义组件的 ref 属性
      if (attr === 'ref' && _.isFunction(vdom.attributes[attr])) {
        vdom.attributes[attr](component)
      }
    }
    ...
  }
  ...
}
```

跑如下测试用例：

```js
class A extends Component {
  constructor() {
    super()
    this.state = {
      count: 0
    }
    this.click = this.click.bind(this)
  }

  click() {
    this.setState({
      count: ++this.state.count
    })
  }

  render() {
    return <div>{this.state.count}</div>
  }
}

class B extends Component {
  constructor() {
    super()
    this.click = this.click.bind(this)
  }

  click() {
    this.A.click()
  }

  render() {
    return (
      <div>
        <button onClick={this.click}>加1</button>
        <A ref={(e) => { this.A = e }} />
      </div>
    )
  }
}
```

效果如下：

![](http://with.muyunyun.cn/reactref%E6%B5%8B%E8%AF%951)

### 鸣谢
Especially thank [simple-react](https://github.com/hujiulong/simple-react) for the guidance function of this library. At the meantime，respect for [preact](https://github.com/developit/preact) and [react](https://github.com/facebook/react)