---
title: redux middleware 源码分析
copyright: true
abbrlink: 7f9a92dc
date: 2018-02-25 21:44:22
tags: ['redux', 'redux-middleware', 'redux-thunk']
categories: ['redux']
---

![](http://with.muyunyun.cn/39bbe72c55363dedf1f69673a58e01cb.jpg-muyy)

<!--more-->

### middleware 的由来

在业务中需要打印每一个 action 信息来调试，又或者希望 dispatch 或 reducer 拥有异步请求的功能。面对这些场景时，一个个修改 dispatch 或 reducer 代码有些乏力，我们需要一个可组合的、自由增减的插件机制，Redux 借鉴了 Koa 中 middleware 的思想，利用它我们可以在前端应用中便捷地实现如日志打印、异步请求等功能。

![](http://with.muyunyun.cn/4ab33429ea461ba24367cc062039836c.jpg-200)

比如在[项目](https://github.com/MuYunyun/reactSPA/blob/274c00870853638fb0f77df8497f911eb560b617/src/client/store/configureStore.dev.js#L14)中，进行了如下调用后，redux 就集成了 thunk 函数调用以及打印日志的功能。

```js
import thunk from 'redux-thunk'
import logger from '../middleware/logger'
const enhancer = applyMiddleware(thunk, logger),  // 以 redux-thunk、logger 中间件为例介绍中间件的使用
const store = createStore(rootReducer, enhancer)
```

下面追本溯源，来分析下源码。

### applyMiddleware 调用入口

```js
export default function createStore(reducer, preloadedState, enhancer) {
  // 通过下面代码可以发现，如果 createStore 传入 2 个参数，第二个参数相当于就是 enhancer
  if (typeof preloadedState === 'function' && typeof enhancer === 'undefined') {
    enhancer = preloadedState
    preloadedState = undefined
  }
  if (typeof enhancer !== 'undefined') {
    return enhancer(createStore)(reducer, preloadedState)
  }
  ...
}
```

由上述 [createStore 源码](https://github.com/reactjs/redux/blob/55e77e88c98723f1883929458bb0144430108143/src/createStore.js#L33)发现，applyMiddleware 会进行 `applyMiddleware(thunk, logger)(createStore)(reducer, preloadedState)` 的调用。

[applyMiddleware 源码](https://github.com/reactjs/redux/blob/55e77e88c98723f1883929458bb0144430108143/src/applyMiddleware.js#L20)如下

```js
export default function applyMiddleware(...middlewares) {
  return createStore => (...args) => {
    const store = createStore(...args)
    let dispatch = store.dispatch
    let chain = []

    const middlewareAPI = {
      getState: store.getState,                // 调用 redux 原生方法，获取状态
      dispatch: (...args) => dispatch(...args) // 调用 redux 原生 dispatch 方法
    }
    // 串行 middleware
    chain = middlewares.map(middleware => middleware(middlewareAPI))
    dispatch = compose(...chain)(store.dispatch)

    return {
      ...store,
      dispatch // 返回加工过的 dispatch
    }
  }
}
```

可以发现 applyMiddleware 的作用其实就是返回加工过的 dispatch，下面会着重分析 middlewares 是如何串行起来的以及 dispatch 是如何被加工的。

### 串行 middleware

```js
const middlewareAPI = {
  getState: store.getState,
  dispatch: (...args) => dispatch(...args)
}
chain = middlewares.map(middleware => middleware(middlewareAPI))
dispatch = compose(...chain)(store.dispatch)
```

观察上述代码后发现每个 middleware 都会传入参数 middlewareAPI，来看下中间件 [logger 的源码](https://github.com/MuYunyun/reactSPA/blob/274c00870853638fb0f77df8497f911eb560b617/src/client/middleware/logger.js#L1) 以及 [redux-thunk 的源码](https://github.com/gaearon/redux-thunk/blob/master/src/index.js), 发现中间件接受的第一个参数正是 ({ dispatch, getState })

```js
// logger 源码
export default ({ dispatch, getState }) => next => action => {
  console.log(action)
  return next(action) // 经 compose 源码分析，此处 next 为 Store.dispatch
}
```

```js
// redux-thunk 源码
export default ({ dispatch, getState }) => next => action => {
  if (typeof action === 'function') {
    return action(dispatch)
  }
  return next(action) // 此处 next 为 logger 中间件返回的 (action） => {} 函数
}
```

### dispatch 是如何被加工的

接着上个小节，在 `dispatch = compose(...chain)(store.dispatch)` 中发现了 compose 函数，来看下 [compose 的源码](https://github.com/reactjs/redux/blob/55e77e88c98723f1883929458bb0144430108143/src/compose.js#L12)

```js
export default function compose(...funcs) {
  // ...
  return funcs.reduce((a, b) => (...args) => a(b(...args)))
}
```

compose 源码中的 `funcs.reduce((a, b) => (...args) => a(b(...args)))` 算是比较重要的一句，它的作用是返回组合参数后的函数，比如 compose(f, g, h) 等价于 (...args) => f(g(h(...args)))，效果图如下所示，调用 this.props.dispatch() 后，会调用相应的中间件，最终会调用 redux 原生的 store.dispatch()，并且可以看到中间件调用的形式类似数据结构中的栈(先进后出)。

![](http://with.muyunyun.cn/201a9431b32d9d9ac2ad5f6712206b3a.jpg-300)

拿上个小节提到的 logger、redux-thunk 中间件为例，其 middleware 的内部串行调用方式如下，从而完成了 dispatch 功能的增强(支持如 `this.props.dispatch(func)` 的调用以及日志功能)。具体可以看 [项目中的运用](https://github.com/MuYunyun/reactSPA/blob/274c00870853638fb0f77df8497f911eb560b617/src/common/pages/music/index.js#L35)

```js
action => {
  if (typeof action === 'function') {
    return action(dispatch)
  }
  return (action => {
    console.log(action)
    return store.dispatch(action)
  })(action)
}
```

### 参考文献

深入React技术栈