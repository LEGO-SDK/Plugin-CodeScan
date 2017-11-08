# Plugin-CodeScan
A LEGO-SDK Plugin with CodeScan API

## Usage
```javascript
opt: Recognition(图片识别),Scan(扫码)

closeAfter: true(opt操作后将关闭操作页面),false(opt操作后将不关闭操作页面)

JSMessage.newMessage('Plugin.CodeScan',{'opt':'Recognition','closeAfter':true}).call(function(meta,res){console.log(res)})
```
