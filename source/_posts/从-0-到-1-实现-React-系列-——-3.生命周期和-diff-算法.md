---
title: 从 0 到 1 实现 React 系列 —— 3.生命周期和 diff 算法
copyright: true
tags:
  - React
categories:
  - React
abbrlink: dc5976f1
date: 2018-07-27 08:13:02
---

![](http://with.muyunyun.cn/9c461a61924ed0fecb6024a256671251.jpg-muyy)

本系列文章在实现一个 cpreact 的同时帮助大家理顺 React 框架的核心内容(JSX/虚拟DOM/组件/生命周期/diff算法/setState/PureComponent/HOC/...) [项目地址](https://github.com/MuYunyun/cpreact)

<!--more-->

* [从 0 到 1 实现 React 系列 —— JSX 和 Virtual DOM](https://github.com/MuYunyun/blog/issues/24)
* [从 0 到 1 实现 React 系列 —— 组件和 state|props](https://github.com/MuYunyun/blog/issues/25)
* [从 0 到 1 实现 React 系列 —— 生命周期和 diff 算法](https://github.com/MuYunyun/blog/issues/26)
* [从 0 到 1 实现 React 系列 —— 优化 setState 和 ref 的实现](https://github.com/MuYunyun/blog/issues/27)
* [从 0 到 1 实现 React 系列 —— PureComponent 实现 && HOC 探幽](https://github.com/MuYunyun/blog/issues/29)

### 生命周期

先来回顾 React 的生命周期，用流程图表示如下：

![](http://with.muyunyun.cn/77e8b5ceaa1d697f280053be91a87bb3.jpg)

该流程图比较清晰地呈现了 react 的生命周期。其分为 3 个阶段 —— 生成期，存在期，销毁期。

因为生命周期钩子函数存在于自定义组件中，将之前 _render 函数作些调整如下：

```js
// 原来的 _render 函数，为了将职责拆分得更细，将 virtual dom 转为 real dom 的函数单独抽离出来
function vdomToDom(vdom) {
  if (_.isFunction(vdom.nodeName)) {        // 为了更加方便地书写生命周期逻辑，将解析自定义组件逻辑和一般 html 标签的逻辑分离开
    const component = createComponent(vdom) // 构造组件
    setProps(component)                     // 更改组件 props
    renderComponent(component)              // 渲染组件，将 dom 节点赋值到 component
    return component.base                   // 返回真实 dom
  }
  ...
}
```

我们可以在 setProps 函数内（渲染前）加入 `componentWillMount`，`componentWillReceiveProps` 方法，setProps 函数如下：

```js
function setProps(component) {
  if (component && component.componentWillMount) {
    component.componentWillMount()
  } else if (component.base && component.componentWillReceiveProps) {
    component.componentWillReceiveProps(component.props) // 后面待实现
  }
}
```

而后我们在 renderComponent 函数内加入 `componentDidMount`、`shouldComponentUpdate`、`componentWillUpdate`、`componentDidUpdate` 方法

```js
function renderComponent(component) {
  if (component.base && component.shouldComponentUpdate) {
    const bool = component.shouldComponentUpdate(component.props, component.state)
    if (!bool && bool !== undefined) {
      return false // shouldComponentUpdate() 返回 false，则生命周期终止
    }
  }
  if (component.base && component.componentWillUpdate) {
    component.componentWillUpdate()
  }

  const rendered = component.render()
  const base = vdomToDom(rendered)

  if (component.base && component.componentDidUpdate) {
    component.componentDidUpdate()
  } else if (component && component.componentDidMount) {
    component.componentDidMount()
  }

  if (component.base && component.base.parentNode) { // setState 进入此逻辑
    component.base.parentNode.replaceChild(base, component.base)
  }

  component.base = base  // 标志符
}
```

#### 测试生命周期

测试如下用例：

```js
class A extends Component {
  componentWillReceiveProps(props) {
    console.log('componentWillReceiveProps')
  }

  render() {
    return (
      <div>{this.props.count}</div>
    )
  }
}

class B extends Component {
  constructor(props) {
    super(props)
    this.state = {
      count: 1
    }
  }

  componentWillMount() {
    console.log('componentWillMount')
  }

  componentDidMount() {
    console.log('componentDidMount')
  }

  shouldComponentUpdate(nextProps, nextState) {
    console.log('shouldComponentUpdate', nextProps, nextState)
    return true
  }

  componentWillUpdate() {
    console.log('componentWillUpdate')
  }

  componentDidUpdate() {
    console.log('componentDidUpdate')
  }

  click() {
    this.setState({
      count: ++this.state.count
    })
  }

  render() {
    console.log('render')
    return (
      <div>
        <button onClick={this.click.bind(this)}>Click Me!</button>
        <A count={this.state.count} />
      </div>
    )
  }
}

ReactDOM.render(
  <B />,
  document.getElementById('root')
)
```

页面加载时输出结果如下：

```
componentWillMount
render
componentDidMount
```

点击按钮时输出结果如下：

```
shouldComponentUpdate
componentWillUpdate
render
componentDidUpdate
```

### diff 的实现

在 react 中，diff 实现的思路是将新老 virtual dom 进行比较，将比较后的 patch（补丁）渲染到页面上，从而实现局部刷新；本文借鉴了 [preact](https://github.com/developit/preact) 和 [simple-react](https://github.com/hujiulong/simple-react) 中的 diff 实现，总体思路是将旧的 dom 节点和新的 virtual dom 节点进行了比较，根据不同的比较类型（文本节点、非文本节点、自定义组件）调用相应的逻辑，从而实现页面的局部渲染。代码总体结构如下：

```js
/**
 * 比较旧的 dom 节点和新的 virtual dom 节点：
 * @param {*} oldDom  旧的 dom 节点
 * @param {*} newVdom 新的 virtual dom 节点
 */
function diff(oldDom, newVdom) {
  ...
  if (_.isString(newVdom)) {
    return diffTextDom(oldDom, newVdom)   // 对比文本 dom 节点
  }

  if (oldDom.nodeName.toLowerCase() !== newVdom.nodeName) {
    diffNotTextDom(oldDom, newVdom)       // 对比非文本 dom 节点
  }

  if (_.isFunction(newVdom.nodeName)) {
    return diffComponent(oldDom, newVdom) // 对比自定义组件
  }

  diffAttribute(oldDom, newVdom)          // 对比属性

  if (newVdom.children.length > 0) {
    diffChild(oldDom, newVdom)            // 遍历对比子节点
  }

  return oldDom
}
```

下面根据不同比较类型实现相应逻辑。

#### 对比文本节点

首先进行较为简单的文本节点的比较，代码如下：

```js
// 对比文本节点
function diffTextDom(oldDom, newVdom) {
  let dom = oldDom
  if (oldDom && oldDom.nodeType === 3) {  // 如果老节点是文本节点
    if (oldDom.textContent !== newVdom) { // 这里一个细节：textContent/innerHTML/innerText 的区别
      oldDom.textContent = newVdom
    }
  } else {                                // 如果旧 dom 元素不为文本节点
    dom = document.createTextNode(newVdom)
    if (oldDom && oldDom.parentNode) {
      oldDom.parentNode.replaceChild(dom, oldDom)
    }
  }
  return dom
}
```

#### 对比非文本节点

对比非文本节点，其思路为将同层级的旧节点替换为新节点，代码如下：

```js
// 对比非文本节点
function diffNotTextDom(oldDom, newVdom) {
  const newDom = document.createElement(newVdom.nodeName);
  [...oldDom.childNodes].map(newDom.appendChild) // 将旧节点下的元素添加到新节点下
  if (oldDom && oldDom.parentNode) {
    oldDom.parentNode.replaceChild(oldDom, newDom)
  }
}
```

#### 对比自定义组件

对比自定义组件的思路为：如果新老组件不同，则直接将新组件替换老组件；如果新老组件相同，则将新组件的 props 赋到老组件上，然后再对获得新 props 前后的老组件做 diff 比较。代码如下：

```js
// 对比自定义组件
function diffComponent(oldDom, newVdom) {
  if (oldDom._component && (oldDom._component.constructor !== newVdom.nodeName)) { // 如果新老组件不同，则直接将新组件替换老组件
    const newDom = vdomToDom(newVdom)
    oldDom._component.parentNode.insertBefore(newDom, oldDom._component)
    oldDom._component.parentNode.removeChild(oldDom._component)
  } else {
    setProps(oldDom._component, newVdom.attributes) // 如果新老组件相同，则将新组件的 props 赋到老组件上
    renderComponent(oldDom._component)              // 对获得新 props 前后的老组件做 diff 比较（renderComponent 中调用了 diff）
  }
}
```

#### 遍历对比子节点

遍历对比子节点的策略有两个：一是只比较同层级的节点，二是给节点加上 key 属性。它们的目的都是降低空间复杂度。代码如下：

```js
// 对比子节点
function diffChild(oldDom, newVdom) {
  const keyed = {}
  const children = []
  const oldChildNodes = oldDom.childNodes
  for (let i = 0; i < oldChildNodes.length; i++) {
    if (oldChildNodes[i].key) { // 将含有 key 的节点存进对象 keyed
      keyed[oldChildNodes[i].key] = oldChildNodes[i]
    } else {                    // 将不含有 key 的节点存进数组 children
      children.push(oldChildNodes[i])
    }
  }

  const newChildNodes = newVdom.children
  let child
  for (let i = 0; i < newChildNodes.length; i++) {
    if (keyed[newChildNodes[i].key]) {  // 对应上面存在 key 的情形
      child = keyed[newChildNodes[i].key]
      keyed[newChildNodes[i].key] = undefined
    } else {                            // 对应上面不存在 key 的情形
      for (let j = 0; j < children.length; j++) {
        if (isSameNodeType(children[i], newChildNodes[i])) { // 如果不存在 key，则优先找到节点类型相同的元素
          child = children[i]
          children[i] = undefined
          break
        }
      }
    }
    diff(child, newChildNodes[i]) // 递归比较
  }
}
```

### 测试

在生命周期的小节中，componentWillReceiveProps 方法还未跑通，稍加修改 setProps 函数即可：

```js
/**
 * 更改属性，componentWillMount 和 componentWillReceiveProps 方法
 */
function setProps(component, attributes) {
  if (attributes) {
    component.props = attributes // 这段逻辑对应上文自定义组件比较中新老组件相同时 setProps 的逻辑
  }

  if (component && component.base && component.componentWillReceiveProps) {
    component.componentWillReceiveProps(component.props)
  } else if (component && component.componentWillMount) {
    component.componentWillMount()
  }
}
```

来测试下生命周期小节中最后的测试用例：

* 生命周期测试

![](http://with.muyunyun.cn/react%E7%94%9F%E5%91%BD%E5%91%A8%E6%9C%9F%E6%B5%8B%E8%AF%951.gif)

* diff 测试

![](http://with.muyunyun.cn/%E7%94%9F%E5%91%BD%E5%91%A8%E6%9C%9Fdiff%E6%B5%8B%E8%AF%951.gif)

### 鸣谢
Especially thank [simple-react](https://github.com/hujiulong/simple-react) for the guidance function of this library. At the meantime，respect for [preact](https://github.com/developit/preact) and [react](https://github.com/facebook/react)