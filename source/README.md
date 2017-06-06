### 牧云云个人网站

博客地址: <http://muyunyun.cn>.

### Makefile使用说明

```
====================A common Makefile for blog system=======================
Copyright (C) 2015 barret.china@gmail.com
The following targets are support:

 i --init             - init, run npm install
 r --run              - start local serve at http://0.0.0.0:4000
 d --deploy           - deploy project to gitcafe & github
 b --backup (P=)      - backup dates, push to git
                         make backup P=1; P->PUSH
 h --help             - show help info
 n --new (N=|P=)      - init new post
                         make new N=postname; N->NEW
                         make new N=postname P=1; P->PUBLISH

To make a target, do make [target], short for make [t]
============================== Version0.1 ==================================
```

### 博客说明

博客在 `muyy` 分支上，`master` 分支为博客静态资源的生成程序。博客基于 [hexo](https://hexo.io) 构建

由于 `github` 的访问速度在国内比较慢，所以网站同时部署在 `coding` 上