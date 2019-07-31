---
title: React Hooks 深入系列
copyright: true
tags:
  - React
categories:
  - React
  - Hooks
abbrlink: 290a4219
date: 2019-05-12 13:23:44
---

![](http://with.muyunyun.cn/34a60f7edb08afaf6d721708ab21b4d7.jpg-muyy)

本文为对 hooks 碎片化的理解。同时欢迎关注基于 hooks 构建的 UI 组件库 —— [snake-design](https://github.com/ming-cult/snake-design)。

<!--more-->

在 class 已经融入 React 生态的节点下, React 推出的 Hooks 具有如下优势:

* 更简洁的书写;
* 相对类中的 `HOC` 与 `render Props`, Hooks 拥有更加自由地组合抽象的能力;

### 使用 Hooks 的注意项

* 在 `hooks` 中每一次 `render` 都有自己的 `state` 和 `props`, 这与 `class` 中存在差异, 见 [Hooks 每次渲染都是闭包](https://overreacted.io/a-complete-guide-to-useeffect/#each-render-has-its-own-everything)
  * `class` 中可以用闭包模拟 `hooks` 的表现, [链接](https://codesandbox.io/s/w7vjo07055), `hooks` 中可以使用 `ref` 模拟 `class` 的表现, [链接](https://codesandbox.io/s/rm7z22qnlp);

* 写出 useEffect 的所用到的依赖

在以下 demo 中, `useEffect` 的第二个参数传入 `[]`, 希望的是 `useEffect` 里的函数只执行一次(类似在 `componentDidMount` 中执行一次, 但是注意这里仅仅是`类似`, 详细原因见上一条注意项), 页面上每隔 1s 递增 1。

```js
function Demo() {
  const [count, setCount] = useState(0);

  useEffect(() => {
    const id = setInterval(() => {
      setCount(count + 1);
    }, 1000);
    return () => {
      clearInterval(id);
    };
  }, []);

  return count;
}
```

但这样达到我们预期的效果了么? [demo](https://codesandbox.io/s/n3o2m1wpj4), 可以看到界面上只增加到 1 就停止了。原因就是传入的第二个参数 `[]` 搞的鬼, `[]` 表示没有外界状态对 `effect` 产生干扰。流程大致如下:

1. 第一次调用 `useEffect` 传入的 `count` 为 0, 于是 `setCount(0 + 1)`;
2. 受 `useEffect` 第二个参数 `[]` 的影响，`count` 仍然为 0, 所以相当于还是 `setCount(0 + 1)`;

那如何修正上述问题呢? 方法有两个(方法一为主, 方法二为辅):

* 方法一: 将 `[]` 改为 `[count]`
* 方法二: 将 `setCount(count + 1)` 改为 `setCount(count => count + 1)`。这种方法的思想是修正状态的值而不依赖外面传进的状态。

不过遇到 `setCount(count => count + 1)` 的情况就可以考虑使用 `useReducer` 了。

#### 何时使用 useReducer

使用 `useState` 的地方都能用 `useReducer` 进行替代。相较 `useState`, `useReducer` 有如下优势:

* `useReducer` 将 `how`(reducer) 和 `what`(dispatch(action)) 进行抽离; 使用 `reducer` 逻辑状态进行集中化维护;
* 相比 useState, useReducer 没有[闭包问题](https://overreacted.io/a-complete-guide-to-useeffect/#each-render-has-its-own-everything);
* 当状态的一个 state 依赖状态中的另一个 state 时, 这种情况最好使用 useReducer; 可以参考 [decoupling-updates-from-actions](https://overreacted.io/a-complete-guide-to-useeffect/#decoupling-updates-from-actions) 中 Dan 列举的 demo。

#### 处理 useEffect 中的公用函数

```js
function Demo() {
  const [count, setCount] = useState(0);

  function getFetchUrl(query) {
    return `http://demo${query}`
  }

  useEffect(() => {
    const url = getFetchUrl('react')
  }, [getFetchUrl]);

  useEffect(() => {
    const url = getFetchUrl('redux')
  }, [getFetchUrl]);

  return count;
}
```

此时 `useEffect` 中传入的第二个参数 `getFetchUrl` 相当于每次都是新的, 所以每次都会请求数据, 那除了 `[getFetchUrl]` 将改为 `[]` 这种不推荐的写法外，有两种解决方法:

*. 方法一: 提升 `getFetchUrl` 的作用域;
*. 方法二: 使用 `useCallback` 或者 `useMemo` 来包裹 getFetchUrl;

> `React.memo` 修饰一个函数组件, `useMemo` 修饰一个函数。它们本质都是运用缓存。

### React Hooks 内部是怎么工作的

为了理解 React Hooks 内部实现原理, 对 `useState`、`useEffect` 进行了简单的实现。

#### useState 的简单实现

使用闭包来实现 `useState` 的简单逻辑:

```js
// 这里使用闭包
const React = (function() {
  let _val

  return {
    useState(initialValue) {
      _val = _val || initialValue

      function setVal(value) {
        _val = value
      }

      return [_val, setVal]
    }
  }
})()
```

测试如下:

```js
function Counter() {
  const [count, setCount] = React.useState(0)

  return {
    render: () => console.log(count),
    click: () => setCount(count + 1)
  }
}

Counter().render() // 0
Counter().click()  // 模拟点击
Counter().render() // 1
```

#### useEffect 的简单实现

```js
var React = (function() {
  let _val, _deps

  return {
    useState(initialValue) {
      _val = _val || initialValue

      function setVal(value) {
        _val = value
      }

      return [_val, setVal]
    },
    useEffect(callback, deps) {
      const ifUpdate = !deps

      // 判断 Deps 中的依赖是否改变
      const ifDepsChange = _deps ? !_deps.every((r, index) => r === deps[index]) : true

      if (ifUpdate || ifDepsChange) {
        callback()

        _deps = deps || []
      }
    }
  }
})()
```

测试代码如下:

```js
var {useState, useEffect} = React

function Counter() {
  const [count, setCount] = useState(0)

  useEffect(() => {
    console.log('useEffect', count)
  }, [count])

  return {
    render: () => console.log('render', count),
    click: () => setCount(count + 1),
    noop: () => setCount(count), // 保持不变, 观察 useEffect 是否被调用
  }
}

Counter().render() // 'useEffect' 0, 'render', 0
Counter().noop()
Counter().render() // 'render', 0
Counter().click()
Counter().render() // 'useEffect' 1, 'render', 1
```

#### 处理多次调用的情形

为了在 `hooks` 中能使用多次 `useState`, `useEffect`, 将各个 `useState`, `useEffect` 的调用存进一个数组中, 在上面基础上进行如下改造:

```js
const React = (function() {
  const hooks = []
  let currentHook = 0

  return {
    render(Component) {
      const component = Component()
      component.render()
      currentHook = 0 // 重置, 这里很关键, 将 hooks 的执行放到 hooks 队列中, 确保每次执行的顺序保持一致。
      return component
    },
    useState(initialValue) {
      hooks[currentHook] = hooks[currentHook] || initialValue

      function setVal(value) {
        hooks[currentHook] = value
      }

      return [hooks[currentHook++], setVal]
    },
    useEffect(callback, deps) {
      const ifUpdate = !deps

      // 判断 Deps 中的依赖是否改变
      const ifDepsChange = hooks[currentHook] ? !hooks[currentHook].every((r, index) => r === deps[index]) : true

      if (ifUpdate || ifDepsChange) {
        callback()

        hooks[currentHook++] = deps || []
      }
    }
  }
})()
```

测试代码如下:

```js
var {useState, useEffect} = React

function Counter() {
  const [count, setCount] = useState(0)
  const [type, setType] = useState('hi')

  useEffect(() => {
    console.log('useEffect', count)
    console.log('type', type)
  }, [count, type])

  return {
    render: () => console.log('render', count),
    click: () => setCount(count + 1),
    noop: () => setCount(count), // 保持不变, 观察 useEffect 是否被调用
  }
}

/* 如下 mock 执行了 useEffect、render; 这里使用 React.render 的原因是为了重置 currentHook 的值 */
let comp = React.render(Counter) // useEffect 0 type hi render 0

/* 如下 mock 只执行了 render */
comp.noop()
comp = React.render(Counter) // render 0

/* 如下 mock 重新执行了 useEffect、render */
comp.click()
React.render(Counter) // useEffect 1, render 1
```

### 相关资源

* [awesome-react-hooks](https://github.com/rehooks/awesome-react-hooks)
* [usehooks](https://github.com/gragland/usehooks)
* [deep-dive-how-do-react-hooks-really-work](https://www.netlify.com/blog/2019/03/11/deep-dive-how-do-react-hooks-really-work/)
* [a-complete-guide-to-useeffect](https://overreacted.io/a-complete-guide-to-useeffect/): 推荐 Dan 的这篇文章
* [Hooks, State, Closures, and useReducer](https://adamrackis.dev/state-and-use-reducer/): 作为 [decoupling-updates-from-actions](https://overreacted.io/a-complete-guide-to-useeffect/#decoupling-updates-from-actions) 的补充
* [Should I useState or useReducer](https://kentcdodds.com/blog/should-i-usestate-or-usereducer/):