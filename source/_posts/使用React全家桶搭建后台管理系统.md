---
title: 使用 React 全家桶搭建一个后台管理系统
copyright: true
abbrlink: 9bfbdbf4
date: 2017-06-15 01:16:07
tags: ['React','Redux']
categories: ['React']
---
![](http://with.muyunyun.cn/007a8b596b798249ed85d11307c959cb.jpg-muyy)

使用React技术栈搭建一个后台管理系统最初是为了上手公司的业务，后来发现这个项目还能把平时遇到的有趣的demo给整合进去。此文尝试对相关的技术栈以及如何在该项目中引人Redux进行分析。
<!--more-->

## 项目地址以及局部展示
* [项目地址](https://github.com/MuYunyun/reactSPA)

* 小模块展示：
![](http://files.cnblogs.com/files/MuYunyun/reactSPA.gif)
* redux在项目中的运用demo展示
![](http://files.cnblogs.com/files/MuYunyun/todoList.gif)

## 项目目录结构
```
├── build.js                   项目打包后的文件
├── config                     webpack配置文件
│   ├──...
│   ├──webpack.config.dev.js   开发环境配置
│   ├──webpack.config.prod.js  生产环境配置
├── node_modules               node模块目录
├── public
│   └──index.html
├── scripts
│   ├── build.js               打包项目文件
│   ├── start.js               启动项目文件
│   └── test.js                测试项目文件
├── src
│   ├── client                 汇聚(入口)目录
│   ├── common                 核心目录
│   │   ├── actions            redux中的action
│   │   ├── components         通用功能组件
│   │   ├── container          通用样式组件
│   │   ├── images
│   │   ├── pages              页面模块
│   │   ├── reducers           redux中的reducer
│   │   ├── utils              工具类
│   │   │   ├── config.js      通用配置
│   │   │   ├── menu.js        菜单配置
│   │   │   └── ajax.js        ajax模块(日后用到)
│   │   └── routes.js          前端路由
│   └── server                 服务端目录(日后用到)
│       └── controller
├── .gitignore
├── package.json
├── README.md
└── yarn.lock
```
项目的初始结构和构造原因已罗列如上，由于过些日子会引人ts，所以项目结构必然还会改动，但肯定基于这基本雏形扩展的。

下面对目录结构作以下说明
* 项目最初始是用 [create-react-app](https://github.com/facebookincubator/create-react-app) 初始化的，create-react-app 是Facebook官方提供的 React 脚手架，也是业界最优秀的 React 应用开发工具之一;
* client 作为入口目录，到时候可以把第三方中间件也放在此处;
* container 和 components 存放的都是 react 组件,区别如下表。但是我把和样式有关的组件就放在container中，把和功能有关的模块(比如自己分装的表格组件、弹出输入框组件等)就放到components中，若日后有需要，container 和 component 组件都是可以在 Redux 数据流中的。

|                       |          container          |       component       |
| :-------------------: | :-------------------------: | :-------------------: |
|         目的          | 如何工作(数据获取,状态更新) | 如何显示(样式，布局)  |
| 是否在 Redux 数据流中 |             是              |          否           |
|       读取数据        |     从 Redux 获取 state     |   从 props 获取数据   |
|       修改数据        |    向 Redux 派发 actions    | 从 props 调用回调函数 |
|       实现方式        |      向react-redux生成      |         手写          |
* ajax 模块到时候计划用 fetch 封装一个ajax，感觉使用 fetch 还是蛮便利的。
* server 层就是作为网关层，日后计划用来写 node 的。

## 技术栈相关
虽然用到的技术栈众多，但是自己也谈不上熟练运用，多半是边查API边用的，所以只罗列些自己用相关的技术栈解决的点;

### webpack(2.x)
4月的时候 create-react-app 还是基于 webpack(1.x) 构建的，5月27号升到了webpack(2.6),于是我也进行了 webpack 的版本升级。
#### 按需加载
[babel-plugin-import](https://github.com/ant-design/babel-plugin-import) 是一个用于按需加载组件代码和样式的 babel 插件，使用此插件后，在引人 antd 相应模块就能实现按需引人，在config/webpack.config.dev.js 文件中作如下修改:
```js
{
        test: /\.(js|jsx)$/,
        include: paths.appSrc,
        loader: require.resolve('babel-loader'),
        options: {
          plugins: [
            "transform-decorators-legacy",  // 引人 ES7 的装饰器 @
            ['import', [{ libraryName: 'antd', style: true }]],
          ],
          cacheDirectory: true,
        },
      },
```
#### 引人less
首先引人 [less-loader](https://github.com/webpack-contrib/less-loader) 来加载 less 样式，同时修改 config/webpack.config.dev.js 文件
```js

        test: /\.less$/,
        use: [
          require.resolve('style-loader'),
          require.resolve('css-loader'),
          {
            loader: require.resolve('postcss-loader'),
            options: {
              ident: 'postcss', //https://webpack.js.org/guides/migrating/#complex-options
              plugins: () => [
                require('postcss-flexbugs-fixes'),
                autoprefixer({
                  browsers: [
                    '>1%',
                    'last 4 versions',
                    'Firefox ESR',
                    'not ie < 9', // React doesn't support IE8 anyway
                  ],
                  flexbox: 'no-2009',
                }),
              ],
            },
          },
          {
            loader: require.resolve('less-loader'),
            options: {
              modifyVars: { "@primary-color": "#1DA57A" },  // 这里利用了 less-loader 的 modifyVars 来进行主题配置， 变量和其他配置方式可以参考 [配置主题](https://ant.design/docs/react/customize-theme-cn) 文档。
            },
          },
        ],
      },
```
#### 一键发布到 gh-pages
用到了 [gh-pages](https://github.com/tschaub/gh-pages) ,使用 npm run deploy 一键发布到自己的gh-pages上，姑且把gh-pages当成生产环境吧，所以在修改config/webpack.config.dev.js 文件的同时也要对 config/webpack.config.prod.js 作出一模一样的修改。
#### 引用路径的缩写
```js
alias: {
      'react-native': 'react-native-web',
      components: path.resolve(__dirname, '..') + '/src/common/components',
      container: path.resolve(__dirname, '..') + '/src/common/container',
      images: path.resolve(__dirname, '..') + '/src/common/images',
      pages: path.resolve(__dirname, '..') + '/src/common/pages',
      utils: path.resolve(__dirname, '..') + '/src/common/utils',
      data: path.resolve(__dirname, '..') + '/src/server/data',
      actions: path.resolve(__dirname, '..') + '/src/common/actions',
      reducers: path.resolve(__dirname, '..') + '/src/common/reducers',
    },
```
配置了引用路径的缩写后，就可以在任意地方如这样引用，比如
```js
import Table from 'components/table'
```
### Antd(2.x)
antd是（蚂蚁金服体验技术部）经过大量的项目实践和总结，沉淀出的一个中台设计语言 Ant Design，使用者包括蚂蚁金服、阿里巴巴、口碑、美团、滴滴等一系列知名公司，而且我从他们的[设计理念](https://ant.design/docs/spec/introduce-cn)也学到了很多关于UI、UX的知识。
该项目采用的是antd最新的版本2.10.0,由于2.x的版本和1.x的版本还是相差蛮大的，之前参考的项目(基于1.x)改起来太费劲，所以在组件那块就干脆自己重新封装了一遍。这部分知识点建议多看文档，官方更新还是非常勤快的。
### React-router(4.x)
react-router 4.x和2.x的差异又是特别的大，召唤[文档](https://reacttraining.com/react-router/web/guides/quick-start),网上基本上都还是2.x的教程，看过文档之后，反正简而言之其就是要让使用者更容易上手。印象最深的是以前嵌套路由写法在4.x中写到同层了。如下示例他们的效果是相同的。

2.x:
```js
<Route path="/" component={App}>
    <Route path="/aaaa" component={AAAA} />
    <Route path="/bbbb" component={BBBB} />
</Route>
```
4.x:
```js
<Route path="/" component={App} />
<Route path="/aaaa" component={AAAA} />
<Route path="/bbbb" component={BBBB} />
```

### Fetch
fetch 使用比较简单，基本的 promise 用法如下
```js
fetch(url).then(response => response.json())
  .then(data => console.log(data))
  .catch(e => console.log("Oops, error", e))
```
此外还能这样用
```js
try {
  let response = await fetch(url);
  let data = await response.json();
  console.log(data);
} catch(e) {
  console.log("Oops, error", e);
}
```
但是其简洁的特点是为了让我们可以自定义其扩展，还是其本身就还不完善呢？我在调用 JSONP 的请求时，发现其不支持对 JSONP 的调用，所幸社区还是很给力地找到了 [fetch-jsonp](https://www.npmjs.com/package/fetch-jsonp) 这个模块，实现了对百度音乐接口调用。fetch-jsonp使用也和 fetch 类似，代码如下
```js
fetchJsonp(url,{method: 'GET'})
　　.then((res) =>res.json())
　　.then((data) => {})
```

### Redux
使用了redux也已经有段时日了，我对redux的定义就是更好的管理组件的状态，一旦应用的逻辑复杂起来，各种组件状态、界面耦合起来，就容易出岔子，redux就是为了解决这个而诞生的，让我们可以更多地关注UI层，而降低对状态的关注。

![](http://with.muyunyun.cn/a40c3540ca26a56b28506d14125c04c1.jpg-400)

画了一幅比较简陋的图来说明 redux 的大致流程，假设首先通过鼠标点击页面上的按钮触发了一个行为(action)，这时我们叫了一辆出租车 dispatch() 将这个 action 带到了终点站 store。这时候 store 就会通过 reducer 函数返回一个新的状态 state，从而改变 UI 显示。之前也写了篇[深入Redux架构](http://www.cnblogs.com/MuYunyun/p/6530715.html)

下面通过把 [代办事项](https://github.com/MuYunyun/todoList) 这个demo运用到后台管理系统中来讲解 Redux 在其中的运用。

首先，在入口目录创建 store
```js
const store = createStore(rootReducer)

ReactDOM.render(
  <Provider store={store}>
    { routes }
  </Provider>,
  document.getElementById('root')
);
```
接着，我使用了 [redux-actions](https://github.com/acdlite/redux-actions) 这个模块。使用 redux-actions 的好处是能简化大量对 action 的声明，以及能简化 reducer 的写法。

代办事项的 actions 文件片段(拿展示全部任务、已完成任务、未完成任务的 action 举例):
```js
import { createAction } from 'redux-actions'

export const setVisibility = createAction('SET_VISIBILITY')
```
没使用 redux-actions 时，actions 写法如下，可看出着实麻烦了不少，
```js
export const setVisibility = (filter) => {
	return {
		type: "SET_VISIBILITY",
		filter
	}
}
```
相应的代办事项的 reducers 文件片段:
```js
export const setVisibility = handleActions({
  'SET_VISIBILITY'(state, action) {
    return { ...state, ...action.payload}
  }
}, 'SHOW_ALL')
```
使用 redux-actions 后，只要进行如下调用,reducers文件里的`SET_VISIBILITY`的 action 就能捕获到`SHOW_ALL`这个状态。
```js
import { setVisibility } from 'actions/todoList'
@connect(
    (state) => ({
        setVisibility: state.setVisibility, // 这个 setVisibility 是取自 reducers 的
    })
)

dispatch(this.props.dispatch(setVisibility('SHOW_ALL')))
```
connect 来自 [react-redux](https://github.com/reactjs/react-redux)，这里的 @ 是 ES7里的装饰器的用法，使用它之后又能减少不少的代码量，原来还要写 `mapStateToProps`、`mapDispatchToProps`。

## 项目的一些扩展计划
计划在该项目把平时工作、学习中遇到的react案例抽离成demo展现出来，所以以后还会多出一些模块。另外过段时间会在该项目中引人 typescript，如果还有精力的话，可以在这个项目上折腾下网关层。喜欢这个项目的话，[点我 Star](https://github.com/MuYunyun/reactSPA)。
