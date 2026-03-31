# Nodejs

卧槽了，nodejs运行Javascript，包含了web服务器，可以方便地与数据库通信，可以方便地播放视频。早知道这个我他妈还费劲的跑tomcat个屁啊

然后跑个HTML就能显示界面了，呜呜呜

node.js 一种javascript的运行环境，能够使得javascript能够脱离浏览器运行。以前js只能在浏览器基础上运行，能够操作的也知识浏览器，比如浏览器上的放大缩小操作，前提是浏览器开启的基础上进行操作（浏览器是客户端）。有了node.js之后，js可以在服务端进行操作，直接在系统上进行操作，可以打开、关闭浏览器等操作。

## NPM

要替换为淘宝镜像



## Nodemon

如果不能使用nodemon命令，可以使用`npx`命令

```
npx nodemon
```



## 使用ejs进行视频网页播放

**代码目录：**

![](src/Nodejs_img/2023-02-26-20-18-26-image.png)

**JavaScript代码：**

```javascript
const express = require('express')
const cors = require("cors");
const app = express()
var ejs = require('ejs')

// 数据区域
const data = require('./data.json')



// app.use(cors())
// 初始化ejs
// app.set('view engine','ejs');
// app.set('views',__dirname+'/views'); // 设置模板位置
// app.use(cors())

app.engine('html',ejs.__express);
app.set('view engine','html');
//设置使用ejs渲染html，所以就不用新建.ejs文件


app.use(express.static(__dirname+'/public'));


console.log(__dirname)
app.get('/movie/:id.html',(req,res)=>{
    // res.send('./index.html');
    let id = req.params.id;
    // let videoid = '/movie/'+String(id)+'.mp4';
    let videoid = '/movie/video'+String(id)+'.mp4';
    console.log (id);
    res.render('index',{detail:videoid})
    console.log(videoid)
  
 
}) 
 
app.listen(8080,()=>{
    console.log("http://127.0.0.1:8080/movie/1.html")
    
})

```



**index.html代码：**

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Document</title>
</head>
<body>
    
    <video controls autoplay src="<%= detail %>"></video>
    <!-- 使用此方法和js端通信 -->
    <h1><%= detail %></h1>
</body>
</html>
```





# 部署cloudflare pages

> 前情提要：GitHub pages部署需要网页完全开源（对于白嫖党来说），这样网页每次的commit都会公开

使用cloudflare pages部署的好处是，直接看到网页的最终界面，每次修改的commit就会隐藏起来。具体流程是：本地静态网页->push到闭源仓库github.io->触发cloudflare拉取并重新部署->看到页面



## 搭建cloudflare pages

创建应用，选择 **想要部署pages**，然后选择导入现有仓库即可，肥肠的便捷！

![image-20260331212230758](src/image-20260331212230758.png)

完成部署后，会得到一个后缀为pages.dev的网页，但是太难记了，因此需要一个简单点的域名~

## 域名

使用的是阿里云35 元/year的top域名，比如我的网页为www.sophda.top

如果是使用阿里云进行域名解析的话，只能建立从 `www.sophda.top->pages.dev`的映射，如果我在网页里输入 `sophda.top`的时候，是无法跳转到网站的。

因此需要将阿里云的dns域名解析服务器修改为cloudflare的，无他，cloudflare牛逼！支持cname到cname的解析。

在cloudflare后台添加两条映射规则：

![image-20260331212826732](src/image-20260331212826732.png)



## 自动更新仓库

> 我是在GitHub的notebook仓库更新的，如果使用api去获取仓库的内容，容易被GitHub ban掉。所以要在pages目录clone一个仓库，并自动cloud flare自动pull仓库

1. 通过Python部署脚本，实现pages更新时，自动clone/pull仓库
2. 通过webhook，当notebook仓库有push更新是，通过hook触发cloudflare pages的构建

