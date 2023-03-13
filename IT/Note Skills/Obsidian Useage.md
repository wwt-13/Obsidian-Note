#Tutorial/Obsidian

---

> 由于Notion不支持本地存储[^1]+中英文输入法逆天bug+不支持样式自定义等等
> 现决定将笔记进行迁移**Notion->Obsidian**,同时也是为了对自己的笔记内容进行一次精炼+复习**Markdown**语法+**Mermaid**语法

- [Obsidian官方文档](https://publish.obsidian.md/help-zh/)
- [Obsidian官方论坛](https://forum-zh.obsidian.md/top?period=monthly)

## What is Obsidian

> **Quote from the official document👇🏻:**
> Obsidian is a powerful **knowledge base** on top of a **local folder** of plain text Markdown files.

对于ob，有几点需要认知清楚

1. 它是<u>知识库管理工具</u>，而不仅仅是一个Markdown编辑器（笔记关联+完备的插件体系使得_Obsidian_在一众双链笔记软件中脱颖而出）
2. ob是==本地存储==的软件，_**数据掌握在自己的手上**_[^2]（震声！）
3. ob构建与.md只上，使得其数据格式能与市面上大部分主流软件兼容（虽然兼容的没那么好就是了[^3]）
4. 文件导出pdf功能优秀[^2]（几乎能做到所见即所得[^4]，这也是我弃用Notion的一大原因）
5. 个人使用完全免费（只有_Cloud Sync_需要收费，但是同样有免费的_**Git**_作为平替）

## Markdown in Obsidian

> 将会讲解Obsidian特有的语法和Markdown中使用不太熟练的语法

### 标签

> 标签是一个组织大量笔记的好方法，它能让你更容易找到笔记。标签本质上是一个可点击的检索按钮, 点击它 Obsidian 就会自动为你搜索包含这个标签的笔记

这是一个标签👉🏻      #Test
这是一个嵌套标签👉🏻   #Test/SubTest

> [!tip] 标签的使用规范
> 对于**文章内**的某些特定内容，对其添加标签，也可以在文章的==**最前面**==对文章整体添加标签（因为点击标签后会默认跳转到文内标签出，总不希望跳转到文章末尾吧）

### 链接

> 链接是一种产生联系的方式，而产生联系的对象包括但不限于笔记、笔记的部分内容、文件(png、mp4....)、网页等等

#### 内部链接

> 内部链接值得是从库中某篇笔记出发，指向库中其他文件的链接

- _格式1_：`[[note or filename]]`
  该方式会链接到给出的文件名，但是不会直接在页面上渲染它，它会以类似网页链接的形式存在，并且只有光标移动到其上是才会显示预览
- _格式2_：`![[note or filename]]`
  和上面类似，只是此方法会对引用内容进行实时渲染

关于笔记链接🔗

1. `[[name]]`单纯链接到某篇笔记
   [[2023-03-08]]
2. `[[name#headname]]`链接到笔记的某个标题
   [[2023-03-08#为什么会出现这样的问题？]]
3. `[[name#headname^block]]`链接到笔记的某个段落
   [[2023-03-08#^870b87]]

| Example1  | Example2   |
| --------- | ---------- |
| [[TEST1]] | ![[TEST1]] |

#### 外部链接

> 顾名思义，就是链接到Ob仓库外部的文件，多指在线图片、网页链接等等

- 格式1：`[显示的文本内容](链接地址)` 用于引用网页链接🔗
- 格式2：`![显示的文本内容](链接地址)` 用于引用在线图片（图床文件等等）

> [!Tip]
> 需要注意的是，和内链不同，`[]()` 无法用于直接渲染网页，需要使用html的_**iframe**_标签才行

[Baidu](https://www.baidu.com)

> [!note] 关于图片大小的调整
> 均可通过在文件名后+`|widthxheight`来进行调整(单位为像素)，比如说👇🏻
> ![[CleanShot 2023-03-08 at 18.54.38.png|400x100]]

### Callouts

> 和Notion中的callout很类似（或者干脆就是一个东西），旨在声明特殊目的时寄予强调，比方说声明“这是一个<font color="red">BUG</font>”

默认有$12$种风格的Callout，每一种都有不同的颜色和图标👇🏻(对于常用的部分已特别标出)

- $note$
- abstract, $summary$, tldr
- info, $todo$
- $tip$, $hint$, $important$
- success, check, $done$
- question, $help$, faq
- $warning$, caution, $attention$
- failure, $fail$, missing
- danger, $error$
- $bug$
- $example$
- $quote$, cite

_**使用基本语法**_：`>[!callout] title \n content`

callout默认是展开的，但是也可以通过设置使其能够**折叠**

1. > [!callout]+:可折叠
2. > [!callout]-:默认处于折叠状态

部分callout使用演示👇🏻

> [!note]+ 笔记
> 一般用于记录知识点等等

> [!summary]+ 总结
> 对于之前所记录的内容进行总结，一般放置于一个heading的最后

> [!todo]+ 任务
> 还未完成的部分内容

> [!tip]+ 重点
> 重要知识点，用于强调

> [!done]+ 已完成
> 已完成的部分任务

> [!fail]+ 失败
> 未完成的任务或者失败的任务

> [!help]+ 帮助
> 用于放置提示、帮助文档等等内容

> [!warning]+ 警告
> 低级警告，需要注意但是误伤大雅

> [!error]+ 错误
> 严重警告，不可忽视

> [!bug]+ bug
> 代码出现了暂时无法解决的bug

> [!example]+ 样例
> 举例或者是用于代码测试的样例

> [!quote]+ 引用
> 用于对网站内容，教授言论等等进行应用，可以配合脚注使用

## Settings of Obsidian

### 代码高亮

> 注意一下Obsidian中支持的语言高亮类型(尝尝出现因为语言类型写错导致代码无法高亮的情况)

```txt
markup+css+clike+javascript+abap+abnf+actionscript+ada+agda+al+antlr4+apacheconf+apex+apl+applescript+aql+arduino+arff+asciidoc+aspnet+asm6502+asmatmel+autohotkey+autoit+avisynth+avro-idl+bash+basic+batch+bbcode+bicep+birb+bison+bnf+brainfuck+brightscript+bro+bsl+c+csharp+cpp+cfscript+chaiscript+cil+clojure+cmake+cobol+coffeescript+concurnas+csp+coq+crystal+css-extras+csv+cypher+d+dart+dataweave+dax+dhall+diff+django+dns-zone-file+docker+dot+ebnf+editorconfig+eiffel+ejs+elixir+elm+etlua+erb+erlang+excel-formula+fsharp+factor+false+firestore-security-rules+flow+fortran+ftl+gml+gap+gcode+gdscript+gedcom+gherkin+git+glsl+gn+go+graphql+groovy+haml+handlebars+haskell+haxe+hcl+hlsl+hoon+http+hpkp+hsts+ichigojam+icon+icu-message-format+idris+ignore+inform7+ini+io+j+java+javadoc+javadoclike+javastacktrace+jexl+jolie+jq+jsdoc+js-extras+json+json5+jsonp+jsstacktrace+js-templates+julia+keepalived+keyman+kotlin+kumir+kusto+latex+latte+less+lilypond+liquid+lisp+livescript+llvm+log+lolcode+lua+magma+makefile+markdown+markup-templating+matlab+maxscript+mel+mermaid+mizar+mongodb+monkey+moonscript+n1ql+n4js+nand2tetris-hdl+naniscript+nasm+neon+nevod+nginx+nim+nix+nsis+objectivec+ocaml+opencl+openqasm+oz+parigp+parser+pascal+pascaligo+psl+pcaxis+peoplecode+perl+php+phpdoc+php-extras+plsql+powerquery+powershell+processing+prolog+promql+properties+protobuf+pug+puppet+pure+purebasic+purescript+python+qsharp+q+qml+qore+r+racket+cshtml+jsx+tsx+reason+regex+rego+renpy+rest+rip+roboconf+robotframework+ruby+rust+sas+sass+scss+scala+scheme+shell-session+smali+smalltalk+smarty+sml+solidity+solution-file+soy+sparql+splunk-spl+sqf+sql+squirrel+stan+iecst+stylus+swift+systemd+t4-templating+t4-cs+t4-vb+tap+tcl+tt2+textile+toml+tremor+turtle+twig+typescript+typoscript+unrealscript+uri+v+vala+vbnet+velocity+verilog+vhdl+vim+visual-basic+warpscript+wasm+web-idl+wiki+wolfram+wren+xeora+xml-doc+xojo+xquery+yaml+yang+zig
```

# footnote

[^1]: Notion最逆天的一点，数据存在云端总觉得没有安全感

[^2]: 又是薄纱Notion的一天

[^3]: 这也是当前众多笔记软件所面临的问题：功能的丰富性和数据格式的兼容性相互掣肘（因为.md的语法结构是定死的，想要扩充功能就只能变相舍弃Markdown的兼容）

[^4]: 几乎的意思当然就是没能完全做到，比如背景色、标题颜色等等还无法完美导出
