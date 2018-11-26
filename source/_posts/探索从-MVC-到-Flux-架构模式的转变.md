---
title: 探索从 MVC 到 MVVM + Flux 架构模式的转变
copyright: true
tags:
  - 框架
  - 状态管理
  - react
categories:
  - 框架
abbrlink: f0f11de9
date: 2018-02-10 10:12:32
---

![](http://with.muyunyun.cn/77fcc2250cfde1b47300673eb3006c8c.jpg-muyy)

在业务中一般 MVVM 框架一般都会配合上数据状态库(redux, mobx 等)一起使用，本文会通过一个小 demo 来讲述为什么会引人数据状态库。

<!--more-->

### 从 MVC 到 MVVM 模式说起

传统 MVC 架构(如 JSP)在当今移动端流量寸土寸金的年代一个比较头疼的问题就是会进行大量的全局重复渲染。但是 MVC 架构是好东西，其对数据、视图、逻辑有了清晰的分工，于是前端 MVC 框架(比如 backbone.js) 出来了，对于很多业务规模不大的场景，前端 MVC 框架已经够用了，它也能做到前后端分离开发单页面应用，那么它的缺陷在哪呢？

拿 backbone.js 说，它的 Model 对外暴露了 set 方法，也就是说可以在不止一个 View 里修改同个 Model 的数据，然后一个 Model 的数据同时对应多个 View 的呈现，如下图所示。当业务逻辑过多时，多个 Model 和多个 View 就会耦合到一块，可以想到排查 bug 的时候会比较痛苦。

![](http://with.muyunyun.cn/779649b773473d622881577730d81be7.jpg-200)

针对传统 MVC 架构性能低(多次全局渲染)以及前端 MVC 框架耦合度高(Model 和 View) 的痛处，MVVM 框架完美地解决了以上两点。可以参阅之前写的 [MVVM 框架解析之双向绑定](https://github.com/MuYunyun/blog/issues/11)

### only MVVM

假设有这么一个场景，在输入框中查询条件，点击查询，然后在列表中返回相应内容。如下图所示：

![](http://with.muyunyun.cn/ecb63d73e997ebf901552c2a89a991c8.jpg-200)

假设用 react 实现，思路大体是先调用查询接口，调用成功后将获取到的数据通过 `setState` 存进 list 中，列表显示部分代码如下：

```js
const Decorate = (ListComponent) => class extends Component {
  constructor() {
    super()
    this.state = { list: [] }
  }

  componentDidMount() {
    fetch('./list.json')
      .then((res) => res.json())
      .then(result => this.setState({ list: result.data }))
  }

  render() {
    return (
      <ListComponent data={this.state.list} />
    )
  }
}
```

接着往封装的 Decorate 组件里，传入无状态函数构建的 List 组件用来展示列表数据，代码如下：

```js
function List(props) {
  return (
    <div>
      {props.data.map(r =>
        <p key={r.id}>{r.content}</p>
      )}
    </div>
  )
}
```

可以看到 List 组件相当于是 View 层，而封装的 Decorate 组件相当于是 Model 层。但是这么做还是把业务逻辑写进了组件当中。而我们期望的是能得到一个纯粹的 Model 层和 View 层。接着一起看看 Flux 架构模式是如何解决这个问题的。

### 引人 Flux 架构模式

![](http://with.muyunyun.cn/77fcc2250cfde1b47300673eb3006c8c.jpg-200)

Flux 架构模式的 4 个重要组成部分以及它们的关系如上图所示，下文会根据 dispatch，store, action, view 的顺序逐步揭开 Flux 架构模式的面纱。

从 [Flux 的源码](https://github.com/facebook/flux/blob/master/src/Dispatcher.js)中可以看出 Dispacher.js 是其的核心文件，其核心是基于事件的发布/订阅模式完成的，核心源码如下：

```js
class Dispatcher {
  ...
  // 注册回调函数，
  register(callback) {
    var id = _prefix + this._lastID++;
    this._callbacks[id] = callback;
  }

  // 当调用 dispatch 的时候会调用 register 中注册的回调函数
  dispatch(payload) {
    this._startDispatching(payload);
    for (var id in this._callbacks) {
      this._invokeCallback(id);
    }
  }
}
```

回顾下之前的目的：让 Store 层变得纯粹。于是定义了一个变量 comments 用来专门存放列表数据，在了解 Dispatcher 的核心原理之后，当调用 dispatch(obj) 方法时，就可以把参数传递到事先注册的 register 函数中，代码如下：

```js
// commentStore.js
let comments = []
const CommentStore = {
  getComment() {
    return comments
  }
}

dispathcer.register((action) => { // 调用 Dispatcher 实例上的 register 函数
  switch (action.type) {
    case 'GET_LIST_SUCCESS': {
      comments = action.comment
    }
  }
})
```

以及 action 中的函数如下：

```js
// commentAction.js
const commentAction = {
  getList() {
    fetch('./list.json')
      .then((res) => res.json())
      .then(result =>
        dispathcer.dispatch({ // 调用 Dispatcher 实例上的 dispatch 函数
          type: 'GET_LIST_SUCCESS',
          comment: result.data
        }))
  }
}
```

但是似乎少了点什么，当 `GET_LIST_SUCCESS` 成功后，发现还缺少通知到页面再次调用 CommentStore.getComment() 的能力，所以再次引用事件发布/订阅模式，这次使用了 Node.js 提供的 events 模块，对 commentStore.js 文件进行修改，修改后代码如下：

```js
let comments = []
const CommentStore = Object.assign({}, EventEmitter.prototype, {
  getComment() {
    return comments
  },

  emitChange() {
    this.emit('change')
  },

  addListener(callback) { // 提供给页面组件使用
    this.on('change', callback)
  }
})

appDispathcer.register((action) => {
  switch (action.type) {
    case 'GET_LIST_SUCCESS': {
      comments = action.comment
      CommentStore.emitChange() // 有了这行代码，也就有了通知页面再次进行调用 CommentStore.getComment 的能力
    }
  }
})
```

剩下最后一步了，就是整合 store 和 action 进页面中，代码如下:

```js
class ComponentList extends Component {
  constructor() {
    super()
    this.state = {
      comment: commentStore.getComment()
    }
  }

  componentDidMount() {
    commentStore.addListener(() => this.setState({ // 注册函数，上面已经提过，供 store 使用
      comment: commentStore.getComment()
    }))
  }

  render() {
    return (
      <div>
        {this.state.comment.map(r =>
          <p key={r.id}>{r.content}</p>
        )}
      </div>
    )
  }
}
```

### 小结

单纯以 mvvm 构建应用会发现业务逻辑以及数据都耦合在组件之中，引入了 Flux 架构模式后数据和业务逻辑得到较好的分离。但是使用 Flux 有什么缺点呢？在下篇 《聊聊 Redux 架构模式》中会进行分析，下回见。

本文实践案例已上传至 [stateManage](https://github.com/MuYunyun/stateManage)

[系列博客](https://github.com/MuYunyun/blog)，欢迎 Star


