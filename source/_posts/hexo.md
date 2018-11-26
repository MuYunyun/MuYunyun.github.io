---
title: hexo 摸爬滚打之进阶教程
copyright: true
abbrlink: f55182c5
date: 2017-05-29 22:01:26
tags: ['hexo','blog']
categories: ['git']
---
![](http://with.muyunyun.cn/d6b051baa29bb75e6b5f691313a82c33.jpg-muyy)

写博客有三个层次，第一层次是借鉴居多的博文，第二层次是借鉴后经过消化后有一定量产出的博文，第三层次是原创好文居多的博文。在参考了大量前辈搭建hexo的心得后，此文尽量把一些别人未提到的点以及比较好用的点给提出来。所以你在参考本文的时候，应该已经过完了[hexo](https://hexo.io/)。本文有以下内容:
* 快速实现博客压缩
* 文章链接唯一化
* 添加酷炫的打赏二维码
* 自定义JS和CSS
* 添加酷炫的歌单模块以及播放器
* github分支管理博客思路
* 秒传图片到七牛云并展现在博客中
* 将博客同时部署到github和coding
<!--more-->

## 快速实现博客压缩

项目压缩也叫`代码丑化`, 分别对 html、css、js、images进行优化，即把重复的代码合并，把多余的空格去掉，用算法把 images 进行压缩。压缩后的博客，加载速度会有较大的提升，自然能留住更多游客。

蛮多朋友使用了`gulp`对博客进行压缩，这也是一个办法，但在社区逛了下，找到了一个比较好用的模块[hexo-all-minifier](https://github.com/chenzhutian/hexo-all-minifier)，这个模块集成了对 html、css、js、image 的优化。安装上此模块后，只要在根目录下的_config.yml文件中加上如下字段就可对博客所有内容进行压缩。
``` js
html_minifier:
  enable: true
  ignore_error: false
  exclude:

css_minifier:
  enable: true
  exclude:
    - '*.min.css'

js_minifier:
  enable: true
  mangle: true
  output:
  compress:
  exclude:
    - '*.min.js'

image_minifier:
  enable: true
  interlaced: false
  multipass: false
  optimizationLevel: 2
  pngquant: false
  progressive: false
```

## 文章链接唯一化

也许你会数次更改文章题目或者变更文章发布时间，在默认设置下，文章链接都会改变，不利于搜索引擎收录，也不利于分享。唯一永久链接才是更好的选择。

安装

``` js
npm install hexo-abbrlink --save
```
在`站点配置文件`中查找代码`permalink`，将其更改为:

``` js
permalink: posts/:abbrlink/  # “posts/” 可自行更换
```

这里有个知识点：
> 百度蜘蛛抓取网页的规则:  对于蜘蛛说网页权重越高、信用度越高抓取越频繁，例如网站的首页和内页。蜘蛛先抓取网站的首页，因为首页权重更高，并且大部分的链接都是指向首页。然后通过首页抓取网站的内页，并不是所有内页蜘蛛都会去抓取。

搜索引擎认为对于一般的中小型站点，3层足够承受所有的内容了，所以蜘蛛经常抓取的内容是前三层，而超过三层的内容蜘蛛认为那些内容并不重要，所以不经常爬取。出于这个原因所以permalink后面跟着的最好不要超过2个斜杠。

然后在`站点配置文件`中添加如下代码:
``` js
# abbrlink config
abbrlink:
  alg: crc32  # 算法：crc16(default) and crc32
  rep: hex    # 进制：dec(default) and hex
```

可选择模式：
* crc16 & hex
* crc16 & dec
* crc32 & hex
* crc32 & dec

## 添加酷炫的打赏二维码
看了好些博客，支付宝的收款码和微信的收款码都是分开的，且是没有美化过的二维码，让人打赏的欲望自然就下降了。来看一下我的赞赏二维码(支持微信和支付宝支付哟)
![](http://with.muyunyun.cn/134f61fc3181e90acfa945aad72a04a6.png-400)

实现这个酷炫二维码的流程如下：
* 首先，分别获得支付宝和微信的收款码
* 接着到[芝麻二维码](https://www.hotapp.cn/shouqian)里将两张二维码合并
* 最后到[第九工场](http://www.9thws.com/)生成自己喜欢的造型

讲生成的图片pay.png放到根目录的source文件中，并在主题配置文件中加上
``` js
alipay: /pay.png
```

### 打赏字体不闪动
修改文件`next/source/css/_common/components/post/post-reward.styl`，然后注释其中的函数`wechat:hover`和`alipay:hover`，如下：
``` js
/* 注释文字闪动函数
 #wechat:hover p{
    animation: roll 0.1s infinite linear;
    -webkit-animation: roll 0.1s infinite linear;
    -moz-animation: roll 0.1s infinite linear;
}
 #alipay:hover p{
   animation: roll 0.1s infinite linear;
    -webkit-animation: roll 0.1s infinite linear;
    -moz-animation: roll 0.1s infinite linear;
}
*/
```

## 自定义JS和CSS

博主用的是next主题，别的主题目录结构可能不太一样，但是整个框架是一样的，生成方式是一样的，所以引用方式也是相同的

### 添加自定义js样式
* 首先把js文件放在`\themes\next\source\js\src`文件目录下
* 然后找到`\themes\next\layout`目录下的布局文件`_layout.swig`
* 把script引用代码加入到该文件中即可

`<script type="text/javascript" src="/js/src/js文件名.js"></script>`

### 添加自定义css样式
添加外部css样式和引用自定义js代码是一样的，在对应css文件夹内添加自定义外部css样式文件，然后在layout文件中添加引用即可。也可以在`\themes\next\source\css\_custom\custom.styl`文件中进行样式的添加。

## 添加酷炫的歌单模块以及播放器
这个模块借鉴了@[小胡子哥](http://www.barretlee.com/entry/)。根据上面的自定义JS和CSS的知识点不难实现歌单模块以及播放器。效果如下图：
![](http://with.muyunyun.cn/502d78856e46095253e59fd11396b2a4.jpg)
核心代码在`\themes\next\source\js\src\music\nmlist`中，[点击看源码](https://github.com/MuYunyun/MuYunyun.githubio/blob/muyy/themes/next/source/js/src/music/nmlist.js)，其核心思路就是通过jsonp的方式对定义好的歌单进行调用。

在调试的过程中，发现了小胡子哥代码的一个bug：当点击一个专辑暂停后，再点击其他的专辑，这时候点击暂停、播放的控制逻辑有错误。经过排查在nmlist.js文件中的bind方法中加上了`$("#nmPlayer").removeAttr("data-paused")`解决了这个bug。

![](http://with.muyunyun.cn/73d9f4070b81bbdab8f80db388af4a40.jpg)

再接着玩的话，可以给播放器加上歌词的功能。这里有一篇[相关文章](http://frankorz.com/2016/09/30/Hexo-patch/#歌词), 有机会可以去把玩一番。

## github分支管理博客思路
有一个问题，如果我电脑坏了怎么办，因为在github中的我们github.io项目是只有编译后的文件的，没有源文件的，也就是说，如果我们的电脑坏了，打不开了，我们的博客就不能进行更新了，所以我们要把我们的源文件也上传到github上。这个时候我可以选择新建一个仓库来存放源文件，也可以把源文件 push 到 user.github.io 的其他分支。我选择了后者。

### 创建muyy(任意)分支
创建两个分支：master 与 muyy,（这个muyy分支就是存放我们源文件的分支，我们只需要更新muyy分支上的内容据就好，master上的分支hexo编译的时候会更新的）

### 初始化仓库
然后我们再初始化仓库，重新对我们的代码进行版本控制
``` js
git init
git remote add origin <server>
```
`<server>`是指在线仓库的地址。origin是本地分支,remote add操作会将本地仓库映射到云端

### 将博客源文件上传至muyy分支
.gitignore文件作用是声明不被git记录的文件，blog根目录下的.gitignore是hexo初始化带来的，可以先删除或者直接编辑，对hexo不会有影响。建议.gitignore内添加以下内容：
``` js
/.deploy_git
/public
/_config.yml
```
.deploy_git是hexo默认的.git配置文件夹，不需要同步
public内文件是根据source文件夹内容自动生成，不需要备份，不然每次改动内容太多
即使是私有仓库，除去在线服务商员工可以看到的风险外，还有云服务商被攻击造成泄漏等可能，所以不建议将配置文件传上去

依次执行
``` js
git add .
git commit -m "..."
git push origin muyy
```

## 秒传图片到七牛云并展现在博客中
在markdown中写blog的朋友，想必这点是最烦恼的吧，一般来说都要手动上传图片到七牛云，再把链接写到markdown中。逛了逛社区，有人用phthon实现一个自动上传的脚本，但是我觉得还不是特别方便，这时在github上找到一个一键贴图工具[qiniu-image-tool](https://github.com/jiwenxing/qiniu-image-tool)，它支持本地文件、截图、网络图片一键上传七牛云并返回图片引用。Mac 是基于 Alfred 的，其 windows 也有相应版本[windows版本](http://jverson.com/2017/05/28/qiniu-image-v2/)。

按照其要求配置好以后，用截图软件截图后，或者本地图片后 copy，然后直接按设置好的 command+option+v，然后在图片成功上传到七牛云图床上，剪贴板上也有相应的连接。
![](https://raw.githubusercontent.com/jiwenxing/qiniu-image-tool/master/res/local.gif)

## 将博客同时部署到 github 和 coding
通常我们把hexo托管在github，但是毕竟github是国外的，访问速度上还是有点慢，所以想也部署一套在国内的托管平台，目前gitcafe已经被coding收购了，所以就决定部署到coding。但是coding有个不好的地方就是访问自定义域名的站点时，不充值的话会有广告跳转页，所以我现在也是处于观望的态度，先把coding的环境代码也先布置好，等它哪一天广告跳转页没了，就把域名指过去。

### coding 上创建一个新项目
这里只介绍 coding 上面如何创建项目，以及把本地 hexo 部署到 coding 上面
![](http://with.muyunyun.cn/41b27d98189a9164d2b2a47ccbafdbfa.jpg)

### 同步本地 hexo 到 coding 上
把获取到了ssh配置_config.yml文件中的deploy下，如果是第一次使用 coding 的话，需要设置SSH公钥，生成的方法可以参考[coding帮助中心](https://coding.net/help/doc/git/ssh-key.html), 其实和 github 配置一模一样的。

本地打开 `id_rsa.pub` 文件，复制其中全部内容，填写到`SSH_RSA公钥`key下的一栏，公钥名称可以随意起名字。完成后点击“添加”，然后输入密码或动态码即可添加完成。

添加后，在git bash命令输入：
``` js
ssh -T git@git.coding.net
```
如果得到下面提示就表示公钥添加成功了：
``` js
Coding.net Tips : [Hello ! You've conected to Coding.net by SSH successfully! ]
```
想要同时部署到2个平台，就要修改博客根目录下面的_config.yml文件中的deploy如下
根据Hexo官方文档需要修改成下面的形式
``` js
deploy:
  type: git
  message: [message]
  repo:
    github: <repository url>,[branch]
    gitcafe: <repository url>,[branch]

```
所以我是这样的
``` js
deploy:
- type: git
  repo:
    github: https://github.com/MuYunyun/MuYunyun.github.io.git,master
    coding: git@git.coding.net:muyunyun/muyunyun.git,master
```
最后使用部署命令就能把博客同步到coding上面：
``` js
hexo deploy -g
```

### pages服务方式部署
将代码上传至coding之后我们就要开启pages服务了，在pages页面我们只需要将部署来源选择为master分支，然后将自定义域名填写我们自己购买的域名就可以了

### 设置域名解析
现在要实现国内的走coding，海外的走github，只要配置2个CNAME就行。域名解析如下：
![](http://with.muyunyun.cn/c2337ab8ed97d0f825703e8ea80a4123.jpg)

## 参考资料
* [小胡子哥](http://www.barretlee.com/entry/)
* [Hexo Next主题设置和优化](http://www.vitah.net/posts/20f300cc/)
* [Hexo 博客补丁](http://frankorz.com/2016/09/30/Hexo-patch/)
* [Water Sister's Blog](http://www.cduyzh.com/page/3/)
* [Hexo+NexT主题配置备忘](http://blog.ynxiu.com/2016/hexo-next-theme-optimize.html)
* [Cherry's Blog](http://www.cherryblog.site/)
* [Hexo 3.1.1 静态博客搭建指南](http://lovenight.github.io/2015/11/10/Hexo-3-1-1-%E9%9D%99%E6%80%81%E5%8D%9A%E5%AE%A2%E6%90%AD%E5%BB%BA%E6%8C%87%E5%8D%97/)
* [hexo的next主题个性化教程:打造炫酷网站](http://shenzekun.cn/hexo%E7%9A%84next%E4%B8%BB%E9%A2%98%E4%B8%AA%E6%80%A7%E5%8C%96%E9%85%8D%E7%BD%AE%E6%95%99%E7%A8%8B.html)
* [将hexo博客同时托管到github和coding](http://tengj.github.io/2016/03/06/hexo4/)