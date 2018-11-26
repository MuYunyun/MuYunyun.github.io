---
title: 从 0 到 1 实现 React 系列 —— 6.onChange 事件以及受控组件
copyright: true
tags:
  - React
categories:
  - React
abbrlink: da72b66c
date: 2018-09-18 16:00:25
---

![](http://with.muyunyun.cn/9c461a61924ed0fecb6024a256671251.jpg-muyy)

本系列文章在实现一个 cpreact 的同时帮助大家理顺 React 框架的核心内容(JSX/虚拟DOM/组件/生命周期/diff算法/setState/PureComponent/HOC/...) [项目地址](https://github.com/MuYunyun/cpreact)

<!--more-->

### 从一个疑问点开始

接上一章 [HOC 探索](https://github.com/MuYunyun/blog/blob/master/从0到1实现React/8.HOC探索.md#属性代理props-proxy) 抛出的问题 ———— react 中的 onChange 事件和原生 DOM 事件中的 onchange 表现不一致，举例说明如下：

```js
// React 中的 onChange 事件
class App extends Component {
  constructor(props) {
    super(props)
    this.onChange = this.onChange.bind(this)
  }

  onChange(e) {
    console.log('键盘松开立刻执行')
  }

  render() {
    return (
      <input onChange={this.onChange} />
    )
  }
}

/*--------------分割线---------------*/

// 原生 DOM 事件中的 onchange 事件：<input id='test'>
document.getElementById('test').addEventListener('change', (e) => {
  console.log('键盘松开以后还需按下回车键或者点下鼠标才会触发')
})
```

### 拨云见雾

我们来看下 React 的一个 issue [React Fire: Modernizing React DOM](https://github.com/facebook/react/issues/13525)。有两点信息和这篇文章的话题相关。

* Drastically simplify the event system
* Migrate from onChange to onInput and don’t polyfill it for uncontrolled components

从这两点内容我们可以得知下面的信息：

React 实现了一套[合成事件机制](https://reactjs.org/docs/events.html#event-pooling)，也就是它的事件机制和原生事件间会有不同。比如它目前 onChange 事件其实对应着原生事件中的 input 事件。在这个 issue 中明确了未来会使用 onInput 事件替代 onChange 事件，并且会大幅度地简化合成事件。

有了以上信息后，我们对 onChange 事件(将来的 onInput 事件)的代码作如下更改：

```js
function setAttribute(dom, attr, value) {
  ...
  if (attr.match(/on\w+/)) {        // 处理事件的属性:
    let eventName = attr.toLowerCase().substr(2)
    if (eventName === 'change') { eventName = 'input' } // 和现阶段的 react 统一
    dom.addEventListener(eventName, value)
  }
  ...
}
```

### 自由组件以及受控组件

区分自由组件以及受控组件在于表单的值是否由 `value` 这个属性控制，比较如下代码：

```js
const case1 = () => <input />                    // 此时输入框内可以随意增减任意值
const case2 = () => <input defaultValue={123} /> // 此时输入框内显示 123，能随意增减值
const case3 = () => <input value={123} />        // 此时输入框内显示 123，并且不能随意增减值
```

`case3` 的情形即为简化版的受控组件。

### 受控组件的实现

题目可以换个问法：当 `input` 的传入属性为 `value` 时(且没有 onChange 属性)，如何禁用用户的输入事件的同时又能获取焦点?

![](http://with.muyunyun.cn/0fa301946b3f4bf315d742735c333562.jpg-200)

首先想到了 html 自带属性 readonly、disable，它们都能禁止用户的输入，但是它们不能满足获取焦点这个条件。结合前文 `onChange` 的实现是监听 `input` 事件，代码分为以下两种情况：

1.dom 节点包含 `value` 属性、`onChange` 属性
2.dom 节点包含 `value` 属性，不包含 `onChange` 属性

代码如下：

```js
function vdomToDom(vdom) {
  ...
  if (vdom.attributes
    && vdom.attributes.hasOwnProperty('onChange')
    && vdom.attributes.hasOwnProperty('value')) { // 受控组件逻辑
      ...
      dom.addEventListener('input', (e) => {
        changeCb.call(this, e)
        dom.value = oldValue
      })
      ...
    }
  if (vdom.attributes
    && !vdom.attributes.hasOwnProperty('onChange')
    && vdom.attributes.hasOwnProperty('value')) { // 受控组件逻辑
    ...
    dom.addEventListener('input', (e) => {
      dom.value = oldValue
    })
    ...
  }
  ...
}
```

可以发现它们的核心都在这段代码上：

```js
dom.addEventListener('input', (e) => {
  changeCb.call(this, e)
  dom.value = oldValue
})
```

区别是当有 `onChange 属性` 时，能提供相应的回调函数 `changeCb` 通过事件循环机制改变表单的值。看如下两个例子的比较：

```js
const App = () => <input value={123} />
```

效果如下：

![](http://with.muyunyun.cn/353c8119b3c60a7f8f7696633c97ad28.jpg-200)

```js
class App extends Component {
  constructor() {
    super()
    this.state = { num: 123 }
    this.change = this.change.bind(this)
  }

  change(e) {
    this.setState({
      num: e.target.value
    })
  }

  render() {
    return (
      <div>
        <input value={this.state.num} onChange={this.change} />
      </div>
    )
  }
}
```

这段代码中的 `change` 函数即上个段落所谓的 `changeCb` 函数，通过 `setState` 的事件循环机制改变表单的值。

效果如下：

![](http://with.muyunyun.cn/aec70ef0cebf603a0871d61f21e93532.gif)

至此，模拟了受控组件的实现。