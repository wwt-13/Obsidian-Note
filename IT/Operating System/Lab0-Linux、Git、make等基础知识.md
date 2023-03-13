#Linux #Linux/Vim #Linux/Tmux #Git #Makefile #OS #Shell

> **Only record what I need to know and what I'am not so familar with.**

## Linux基础

> [!warning]
> 对于Shell语法而言，可以不求完全掌握，==只要对相关指令有个大概印象，查阅资料后能够灵活使用即可==(因为大部分指令平时都不常用)
> 但是所记录的内容应当==尽量全面==，因为这就是以后上机的参考文件

### 默认参数

> 本次的`Lab0-extra`就考到了其中的部分内容("如何判断diff指令的判断结果？")，所以说细节还是很重要的

常用参数如下所示👇🏻

1. `$#`：传递到脚本的参数个数
2. `$n`：传递到脚本的第几个参数个数
3. `$?`：显示最后命令的`退出状态(exitcode)`。0表示没有error，其他值则表示error
4. `$(command)`：常用，用于返回command这条命令的stdout，比如`$(echo 123)`返回的stdout就是“123”

这里稍微介绍下`$?`(Lab0差点被坑了)

> [!hint]
> 进程执行后，将使用变量`$?`保存状态码的相关数字，不同的值反应成功或失败（0代表成功，非0代表失败）

本次Lab0中有道题的要求是这样的，_"使用diff a b比较文件，如果不同则输出different，相同则输出same"_(大概理解一下把总之就是差不多这样orz)

但是diff这个指令特殊就特殊在它是没有stdout的，所以无法像平常那样通过`[ diff a b ... ]`来判断指令结果，可以通过`man diff`发现该指令会将结果默认保存在退出状态中
![[CleanShot 2023-03-10 at 16.49.09.png]]

然后用上`$?`，问题就解决了(下面是本次Lab0-extra的代码文件)

```shell
#!/bin/bash

if [ $# -eq 1 ];
then
    # Your code here. (1/4)
        # 按照LEVEL分类

        grep -E "WARN|ERROR" $1 > bug.txt

else
    case $2 in
    "--latest")
        # Your code here. (2/4)
                tail --lines=5 $1
    ;;
    "--find")
        # Your code here. (3/4)
                grep "$3" $1 > "$3.txt"
    ;;
    "--diff")
        # Your code here. (4/4)
                diff $1 $3 > /dev/null # 需要将无用输出舍弃
                if [ $? -eq 0 ] # $?用在这里
                then
                        echo "same"
                else
                        echo "different"
                fi
    ;;
    esac
fi
```

#### 关于let造成的bug

> let+表达式，常用于shell脚本中的++、--操作，但是指导书上对于let的描述，是存在一定问题的👇🏻
> “可以通过let a=a-1”实现a--的操作，该指令雀氏可以实现a--，但是let指令有一个蛋疼的地方，就是<mark style="background: #FFB8EBA6;">它在给变量赋值为0的时候，指令的exitcode是1</mark>

首先说明一点，一个bash脚本的exitcode默认是其最后一条指令的exitcode，就像这样👇🏻

```shell
a=3
while [ $a -gt 0 ]
do
	echo $a
	let a=a-1
done
```

该脚本执行的最后一条指令是`let a=0`,这下好了，导致整个bash脚本的exitcode=1，于是乎OS评测机直接报错辣
![[CleanShot 2023-03-11 at 19.09.29.png]]

>[!hint]
> 建议使用let官方给的形式实现++、--，`let a++;let a--`（exitcode不会非0）
> 修改后，脚本不会报错👇🏻
> ![[CleanShot 2023-03-11 at 19.10.03.png|750]]
### 关于`$()` `` ,`${}`,`$[]` `$(())`,`[]` `(())`

> 可以看见heading已经按照`,`分好类了，上面这些其实本质上没有什么联系，只是长得太像容易弄混所以单独拎出来记忆一下

1. `$()`和``：用于获取命令的stdout

2. `${}`：用于获取变量的值

3. `$[]`和`$(())`：均用于进行数学运算，支持+-*/%

   > [!tip]
   > 在$(())、$[]中的变量名称，可于其前面加$符号来替换，也可以不用

   ```shell
   #! /bin/bash
   a=1;b=2;c=3
   echo $((a+b+c))
   a=12
   while [ $a -gt 0 ]
   do
       echo $a
       a=$((a-1))
       echo $a
       a=$[a-1] # 这里尽量不要采用let a=a-1进行复制(容易产生bug)
       echo $a
   done
   ```

4. `[]`：和test命令等价，用于Shell中进行条件判断
   - 必须在_**左括号的右侧和右括号的左侧各加一个空格**_，否则会报错
   - 大于小于符号需要转义，否则会被理解为重定向（所以建议使用`-ne,-eq`等等用于判断大小）
     ![[CleanShot 2023-03-10 at 17.13.36.png]][^1]

5. `(())`：常见于_for循环_的条件表达(其他用法可以被上述符号涵盖)，并且for条件中的变量不需要添加`$`，可以像C代码中的循环一样正常使用
   ```shell
   for((i=1;i<10;i++)) # 比C就多了一个括号
   do
       echo $i
   done
   ```

### stdin,stdout,stderr

> 大多数 UNIX 系统命令从你的终端接受输入并将所产生的输出发送回​​到您的终端。一个命令通常从一个叫标准输入的地方读取输入stdin，**默认情况下**，这恰好是你的终端。同样，一个命令通常将其输出写入到标准输出stdout，**默认情况下**，这也是你的终端

Linux系统将所有对象都当做文件来进行处理，这其中包括了**输入**和**输出**进程。同样的，Linux用文件描述符(`file descriptor`)来标识每个文件对象[^2]，某个程序打开文件时，内核返回相应的文件描述符，_文件描述符是一个非负整数，用于唯一标识会话中打开的文件_

> [!important]
> 就像默认参数一样，Shell中也保留了3个标准文件描述：0(stdin),1(stdout),2(stderr)，而后面打开的文件依次类推对应3、4、......

可以通过`cat /proc/sys/fs/file-nr`查看系统打开的文件描述符数量和FD上限

![[CleanShot 2023-03-10 at 19.26.44 1.png]]

### 重定向&管道

#### 重定向

> 通过输出重定向标识符`>`和输入重定向标识符`<`可以将输入输出重定向到其他文件中[^3]

```shell
echo "test" > file1 # 将标准输出重定向到文件file1
# 其实默认情况下，文件描述符1会被省略 `echo "test" 1> file1`
```

同理，可以将标准错误和标准输出都写到两个单独文件中

```shell
ls -ll 2> error.txt 1> output.txt # 直接通过空格分割
```

> [!hint] 小技巧
> 要禁止在屏幕上显示错误消息，请将标准错误流`stderr`重定向到`/dev/null`空设备
>
> ```shell
> ./hello.c 2> /dev/null
> ```

将标准错误重定向到标准输出👇🏻

```shell
# `> file`将command的标准输出重定向到file，`2>&1`将command的标准错误重定向到标准输出
gcc -o main.c main.o > output 2>&1
# 也可已通过重定向追加的方式实现
gcc -o main.c main.o > output 2>>output
# 经过检验，两者的output文件内容一致
```

同时替换输入输出

```shell
# 指定command1，从infile中获取输出，然后将输出写入outfile中
command1 < infile > outfile
```

> [!note]
> 对于重定向输入理解的还不是很透彻，但就课程内也肯定够用了

#### 管道

> 管道命令的操作符是：`|`
> 管道和重定向的定义非常类似，它处理由前一个指令传出的输出信息(但是无法处理标准错误)，然后传递给下一条指令作为标准输入
> ![[Untitled.png]]

> [!atttention] 管道和重定向的区别
> 左边的命令应该有标准输出 `|` 右边的命令应该接受标准输入
> 左边的命令应该有标准输出 `>` 右边只能是文件
> 左边的命令应该需要标准输入 `<` 右边只能是文件

一条利用管道实现的实用的排除删除指令👇🏻

```shell
# 删除当前目录下除了Makefile和fib.c外所有文件
ls | grep -v -E "Makefile|fib.c" | xargs rm
# 对于该指令的具体解释之后再说
```

### 判断&循环

> 判断：if...then...elif...else...fi
> 循环：👇🏻
>
> - while...do...done
> - for condition do...done

简单没什么好说的，直接上例子

```shell
a=5;b=10
if [ $a -gt 0 ] && [ $b -le 100 ] # 条件判断
then
	echo "range correct"
elif [ $a -eq 0 ]
	echo "a=0"
else
	echo "range incorrect"
fi # 结束符
# for循环会更加复杂一点
for i in a b c # 空格隔开的变量
do
	...
done
for i in $(grep -n "test" ./*|awk -F: '{print $2}') # 命令返回的结果
do
	....
done
for i in $(seq 1 10) # seq命令生成的整数序列
do
	....
done
for((i=1;i<10;i++)) # 和C几乎完全一致的写法
do
	....
done
```

### Specific Commands

> 重头戏，查询、替换等等常用特殊指令的使用(指导书上虽然有些但是实在太简略了)

#### find

> ==文件名==检索指令，用于在指定目录下查找符合自己列举条件的文件
> 需要注意的是，**find指令默认实行递归查找**

指令基本格式：`find [path] [expression]`,比如`find . -name "file"`

常用options如下：

- `-name`:`find . -name "test"`查找当前目录下名为test的文件
- `-type`:`find . -type d -name "test"`查找当前目录下名为test的==目录==，_f代表文件，d代表目录_
- `-perm`:`find . -perm 755`查找当前目录下文件权限为755的文件
- `-exec`:`find . -name "test" -exec rm  -rf {} \;`对匹配的文件执行该参数所给出的shell命令，注意-exec的格式`-exec command {} \;`

#### grep

> ==依据文件内容的文件检索指令==，默认显示匹配文件名和匹配行

指令基本格式：`grep [options] pattern path`

| 参数 | 含义                                                |
| -- | ------------------------------------------------- |
| -c | 只输出匹配行的计数(貌似使用-c后，也会显示0的计数)                       |
| -l | 只输出包含pattern的文件名(独立显示，不会显示0的计数)                   |
| -h | 不显示文件名(像-h -c就只会显示行的计数)                           |
| -n | 显示匹配行和行号                                          |
| -v | **反向显示**，输出不包含pattern的==匹配行==(该option和xargs结合很有用) |
| -r | 文件夹递归查找                                           |
| -E | pattern支持更多正则表达式[^4]                              |

> [!hint]
> 要想搜索目录下文件的话，路径应该为`./*`，并且因为grep也会尝试搜索文件夹[^5]，对文件夹执行grep命令还会报`grep: ./assemble_test: is a directory`❌，所以还推荐将标准错误重定向只空外设`2>/dev/null`

示例如下👇🏻

1. `grep "test" ./* 2>/dev/null`搜索当前目录下包含test的文件
   ```shell
   ./test.c:test
   ./test.c:test
   ./test.c:test
   ```
2. `grep -n "test" ./* 2>/dev/null`:搜索当前目录下包含test的文件，并且显示匹配行和行号
   ```shell
   ./test.c:1:test
   ./test.c:2:test
   ./test.c:3:test
   ```
3. `grep -l "test" ./* 2>/dev/null`:搜索当前目录下包含test的文件，只显示文件名
   ```shell
   ./test.c
   ```
4. `find . -name "*.c" -exec grep -n "test" {} \;`:find和grep指令结合
   ```shell
   1:test
   2:test
   3:test
   ```

> [!todo]
> grep指令还能和xargs结合写出保留文件夹下指定文件的删除指令，这点将在xargs中进行讲解

#### xargs

> 该指令用于给命令传递参数(？那不是和管道的作用冲突了吗)
> 戳啦，因为很多命令都不支持管道传参，所以xargs才有了存在的必要(说白了就是一个用于辅助管道的命令)

常见的xargs命令格式：`command | xargs [-options] command`

因为OS中用到的功能比较基础，就不赘述`-options`的内容了

```shell
find /sbin -perm +700 | ls -ll # wrong
find /sbin -perm +700 | xargs ls -ll # right
```

_**保留指定文件的删除指令👇🏻**_

```shell
ls | grep -v -E "file1|file2|..." | xargs rm -rf
# 注意细节，grep需要-E指令才能支持bash通配符|
# -v代表反向匹配
```

#### sed

> 功能强大的流式文本编辑器
> 需要注意的是，sed默认不会直接修改源文件的数据，而是将数据复制到缓冲区中进行处理(当然可以通过指定`-i`选项来修改源文件)

> [!hint] 什么是流式？
> 就是以行为读取单位，每次处理一行，往复循环至文件结束

命令格式：`sed [options] 'command' files`

| options | 功能                                    |
| ------- | ------------------------------------- |
| -n      | 安静模式(只输出command匹配行，否则sed会自动在末尾输出文件内容) |
| -e      | 进行多项编辑(可以实现多条sed语句同时编辑)               |
| -i      | 直接修改文档内容                              |

> [!warning]
> sed的用法多的离谱，并且其中的语法结构相当混乱(个人认为)，所以只能尽量按照个人理解记下平时比较常见的sed指令
> 还有一点，sed的输出也较为混乱(p,-n等等),建议上机用到的时候多试试

##### 输出p

> 简单的输出指令

```shell
sed -n '3p' filename # 输出第3的内容
sed -n '2,4p' filename # 输出2-4行的内容
```

##### 替换s

> 顾名思义，是指command开头为s的指令

```shell
sed -n 's/test1/test2/g' filename # s代表替换，g代表全匹配
sed -n '1,3s/test1/test2/g' filename # 只匹配1-3行的内容
sed -n 's/test1/test2/2' filename # 只替换每行的第2个test1
sed -n "s/third/test/w tmp" output.txt # 将匹配行输出到tmp文件中
```

##### 删除d

> 与其说是删除，不如说是**反向输出**

```shell
sed '2d' filename # 输出filename中除了第2行外的内容
sed '2,5d' filename # 排除输出filename中第2-5行的内容
```

##### 写入w

> 将文件的指定行写入另外一个文件

```shell
# 只介绍下上机中遇到了题目
sed -n -e '8w BBB' -e '32w BBB' -e '128w BBB' -e '512w BBB' -e '1024w BBB' AAA
```

#### awk

> 流式处理的字符串分割指令（因为平时用的比较多的也只有字符串分割这一块内容了hh）

基本指令格式：`awk -F sign 'command' {filenames}`(注意-F和sign是两个参数)

在`command`中👇🏻

- `$0`代表整个文本行
- `$1`代表文本行中的第1个数据字段
- `$2`代表文本行中的第2个数据字段
- `$n`代表文本行中的第n个数据字段

```shell
# 指定分隔符为r，并且输出分割的第一项内容
awk -F 'r' '{print $1}' output.txt
```

## Vim&Tmux

## Git

## Makefile

> 用于构建项目的神器，用于指定项目应该怎么样去编译和链接程序
> 说白了就是经过优化的特定用于构建项目的脚本文件(不嫌麻烦的话用.sh也可以实现相同的效果)

> [!important]
> 学习Makefile，需要明确自己学习的目的是什么，不能闷头死学，那样的话到头来只会发现自己学了一大堆没用的make指令
> 本文以读懂下列Lab1主Makefile文件为目的👇🏻
> [[include.mk]]、[[Makefile]]

##### include.mk和makefile

`include.mk`

```cmake
# ENDIAN is either EL (little endian) or EB (big endian)

ENDIAN := EL

  

CROSS_COMPILE := mips-linux-gnu-

CC := $(CROSS_COMPILE)gcc

CFLAGS += --std=gnu99 -$(ENDIAN) -G 0 -mno-abicalls -fno-pic -ffreestanding -fno-stack-protector -fno-builtin -Wa,-xgot -Wall -mxgot -mfp32 -march=r3000

LD := $(CROSS_COMPILE)ld

LDFLAGS += -$(ENDIAN) -G 0 -static -n -nostdlib --fatal-warnings

  

HOST_CC := cc

HOST_CFLAGS += --std=gnu99 -O2 -Wall

HOST_ENDIAN := $(shell lscpu | grep -iq 'little endian' && echo EL || echo EB)

  

ifneq ($(HOST_ENDIAN), $(ENDIAN))

# CONFIG_REVERSE_ENDIAN is checked in tools/fsformat.c (lab5)

HOST_CFLAGS += -DCONFIG_REVERSE_ENDIAN

endif
```

`makefile`

```cmake
include include.mk # 引入其他文件的Makefile变量

  

lab ?= $(shell cat .mos-this-lab 2>/dev/null || echo 6)

  

# 目标文件夹

target_dir := target

# 目标文件

mos_elf := $(target_dir)/mos

user_disk := $(target_dir)/fs.img

link_script := kernel.lds

  

modules := lib init kern

targets := $(mos_elf)

syms_file := $(target_dir)/prog.syms

gxemul_files += $(mos_elf)

  

lab-ge = $(shell [ "$$(echo $(lab)_ | cut -f1 -d_)" -ge $(1) ] && echo true)

  

ifeq ($(call lab-ge,3),true)

user_modules += user/bare

endif

  

ifeq ($(call lab-ge,4),true)

user_modules += user

endif

  

ifeq ($(call lab-ge,5),true)

user_modules += fs

targets += fs-image

endif

  

gxemul_flags += -T -C R3000 -M 64

CFLAGS += -DLAB=$(shell echo $(lab) | cut -f1 -d_)

  

objects := $(addsuffix /*.o, $(modules)) $(addsuffix /*.x, $(user_modules))

modules += $(user_modules)

  

.PHONY: all test tools $(modules) clean run dbg objdump fs-image clean-and-all

  

.ONESHELL:

clean-and-all: clean

$(MAKE) all

  

test: export test_dir = tests/lab$(lab)

test: clean-and-all

  

include mk/tests.mk mk/profiles.mk

# 将export后的变量传递给了所有子make(当前目录内的所有make,但是子目录的export无法向父目录传递)

export CC CFLAGS LD LDFLAGS lab

  

# Make运行的所有指令(依赖传递)

all: $(targets)

# $(targets)->$(mos-elf)->...

# $(mos_elf): $(modules) $(target_dir)

# $(LD) $(LDFLAGS) -o $(mos_elf) -N -T $(link_script) $(objects)

  

$(target_dir):

mkdir -p $@

  

tools:

CC="$(HOST_CC)" CFLAGS="$(HOST_CFLAGS)" $(MAKE) --directory=$@

  

$(modules): tools

$(MAKE) --directory=$@

  

$(mos_elf): $(modules) $(target_dir)

$(LD) $(LDFLAGS) -o $(mos_elf) -N -T $(link_script) $(objects)

  

fs-image: $(target_dir) user

$(MAKE) --directory=fs image fs-files="$(addprefix ../, $(fs-files))"

  

fs: user

user: lib

  

clean:

for d in * tools/readelf user/* tests/*; do

if [ -f $$d/Makefile ]; then

$(MAKE) --directory=$$d clean

fi

done

rm -rf *.o *~ $(target_dir) include/generated

find . -name '*.objdump' -exec rm {} ';'

  

ifneq ($(prog),)

dbg:

$(CROSS_COMPILE)nm -S '$(prog)' > $(syms_file)

@gxemul_files=$(syms_file) gxemul_flags=-V $(MAKE) run

else

dbg: gxemul_flags += -V

dbg: run

endif

  

run: gxemul_flags += -E $(shell gxemul -H | grep -q oldtestmips && echo old)testmips \

$(shell [ -f '$(user_disk)' ] && echo '-d $(user_disk)')

run:

gxemul $(gxemul_flags) $(gxemul_files)

  

objdump:

@find * \( -name '*.b' -o -path $(mos_elf) \) -exec sh -c \

'$(CROSS_COMPILE)objdump {} -aldS > {}.objdump && echo {}.objdump' ';'
```

#### MAKE基础

> 了解一些Makefile中的基础语法和Make指令执行基本的基本规则

1. 注释：Makefile中同样使用`#`作为文件的注释
2. 输出：Makefile会默认在命令行中输出一边Make命令执行的语法，可以通过在命令前加上`@`来关闭命令行输出
3. 命令解释器：Makefile的命令默认以`/bin/sh`为解释器，所以某些在`bash`中能运行的指令可能在make中无法运行(比如`rm !(1.txt)`)
4. 行分隔：make指令以行为单位执行，_**每个行分属于不同的make进程**_，所以如果要_进入特定目录执行指令_或者_声明变量后执行指令(该指令需要引用声明的变量)_，需要采取如下形式👇🏻
   ```shell
   cd ../ && ls -ll # 只有在指令1执行成功后才会执行指令2
   cd ../ ; ls -ll # 无论指令1是否成功都执行指令2
   cd ../ ; \ # 通过反斜杠转义的形式，来书写多行命令(和C语法类似)
   ls -ll
   tmp=123 && echo ${tmp}
   tmp=123 ; ehco ${tmp}
   ```

> [!note] `$(MAKE) --directory=path`
> 对于Makefile的行分隔特性，还有另外一种方法可以加以解决👆🏻
> 含义是，前往path目录下，执行子make指令
>
> ```cmake
> tools:
> 	CC="$(HOST_CC)" CFLAGS="$(HOST_CFLAGS)" $(MAKE) --directory=$@
> ```

##### .PHONY

> **.PHONY**配置项的作用在于避免命令和项目下的同名文件冲突
> 它的原理是**显式指定其后跟这的命令名称是命令而不是文件名**

> [!hint]
> 这是因为Makefile有一个很蛋疼的机制，如果`make clean`命令执行时，_**当前目录下已经存在了一个名为clean的文件**_，那么make就会自动认为已达成make目标—>`make: clean' is up to date.`

这时就需要通过`.PHONY`来显式指定`make clean`的`clean`是一个命令名，而不是文件名，这样就不会出现命令和项目文件冲突的情况了

```cmake
.PHONY: clean
clean: 
	touch clean
```

#### 变量

> 在Makefile中，同样使用变量来代替重复使用的内容
> Attention:`makefile`中变量的命名应该遵循==全大写+下划线==结合的形式

基本语法格式：`var = value`，使用则和shell中使用变量稍有区别`$(var)`[^6]

被引用的变量会以字符串的形式展开

```cmake
A = tmp
B = $(A) tmp2 # B = tmp tmp2
```

> [!note] Make赋值运算符
>
> 1. `=` 最基本的赋值，在_**整个Makefile文件展开后才决定变量的值**_
> 2. `:=` 变量的赋值取决于其在Makefile文件中的位置
> 3. `?=` 如果变量未被赋值过，再对其赋值
> 4. `+=` 添加等号后面的值（空格隔开添加在末尾）
>
> ```cmake
> foo1 := $(test1) args
> foo2 = $(test1) args
> foo2 ?= args
> foo2 += hello
> test1 = hello
> # foo1=args
> # foo2=hello args hello
> ```

> [!tip] include导入
> 和C类似，在Makefile中可以使用include关键字导入别的Makefile中声明的变量，一般被依赖的makefile文件后缀使用 `.mk`
>
> ```cmake
> include include.mk
> ```

> [!tip] export导出
> 在Makefile中，可以通过`export+变量名`将该变量传递给其他Makefile文件，传递范围为<mark style="background: #FFB8EBA6;">递归子目录Makefile</mark>(但不包含同级Makefile)
>
> ```cmake
> export CC CFLAGS LD LDFLAGS lab
> ```

##### 隐含变量

> Makefile中预定义的变量，分为两类👇🏻
>
> 1. 代表一个程序的名字（比如CC代表了gcc这个可执行程序）
> 2. 代表了执行程序使用的参数（比如CFLAGS）

下面对一些常见的隐含变量定义进行介绍👇🏻

1. CC：C编译程序，默认为`cc`
2. CFLAGS：执行“CC”编译器的命令行参数
3. LDFLAGS：链接器(ld)参数

> [!quote] cc和gcc
> 如果讨论范围在Unix和Linux之间，那么cc和gcc不是同一个东西。cc来自于Unix的c语言编译器，是 `c compiler` 的缩写。gcc来自Linux世界，是`GNU compiler collection` 的缩写，注意这是一个编译器集合，不仅仅是c或c++
> 但是，如果讨论范围仅限于linux，它们是完全一样的，在linux下调用cc，最终指向的就是gcc编译器集合
>
> 为什么会这样，很简单，为了兼容性：
> cc是Unix下的，是收费的，可不向Linux那样可以那来随便用，所以Linux下是没有cc的
> 然后，问题来了，如果我的c/c++项目是在Unix下编写的，在写makefile文件时自然地用了cc，当将其放到Linux下这无法make了，必须将其中的cc全部修改成gcc。这太麻烦了哈，所以，Linux这想了这么一个方便的解决方案：不修改makefile，继续使用cc，这个cc是个“冒牌货”，它实际指向gcc。
> 该段内容引用自[Linux下的cc和gcc](https://www.cnblogs.com/zhouyinhui/archive/2010/02/01/1661078.html)

#### 模式匹配

> Make命令允许对文件名，进行类似正则运算的匹配，其中主要用到的匹配符是`%`
> `%`匹配符用于匹配一个文件名(任意的非空字符串)

```cmake
%.o: %.c
	......
# 等价于下面的写法
f1.o: f1.c
	......
f2.o: f2.c
	......
```

使用匹配符`%`，可以将大量同类型的文件，只用一条规则就完成构建

##### 自动化变量

> 模式匹配必须和自动化变量配合使用，否则模式匹配匹配了个寂寞

1. `$@`：指代**当前目标**
2. `$<`：指代第一个前置条件
3. `$*`：指代匹配符%匹配的部分内容
4. `$^`：指代所有前置条件，以空格分隔
5. `$?`：指代比目标更新的所有前置条件(不是很理解?)
6. `$(@D)``$(@F)`：分别指向 $@ 的目录名和文件名
7. `$(<D)``$(<F)`：分别指向 $< 的目录名和文件名

```cmake
# 必须指定对应target，模式匹配才能执行
all: test.o test1.o test2.o
%.o: %.c
	$(CC) -c $< -o $@
# 基本最常用的自动化变量就是目标$@和前置条件$<
```

## 参考资料

[简书：Shell自定义输入输出文件描述符](https://www.jianshu.com/p/15239a00f56b)
[Linux：如何获取打开文件和文件描述符数量](https://www.cnblogs.com/mfryf/p/5329770.html)
[linux 中强大且常用命令：find、grep](https://linux.cn/article-1672-1.html)
[阮一峰：Make命令教程](https://www.ruanyifeng.com/blog/2015/02/make.html)
[subinf blog：make和Makefile使用小结](https://www.suninf.net/2016/12/gnu-make-and-makefile.html)

[[guide-book_2023-0.pdf|Lab0实验指导书]]
[[GNU make3.8手册_CN.pdf]]

# footnote

[^1]: 对于Obsidian中表格的书写，我的评价是 **一坨答辩**

[^2]: 也可以称之为文件句柄——FD

[^3]: 注意，Linux讲所有对象均视为文件

[^4]: 之前也支持，开启该选项后支持的更多

[^5]: 这下万物皆文件了

[^6]: Shell中引用变量是 `${}`
