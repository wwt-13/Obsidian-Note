#OS #C #ELF #汇编 #MIPS

> **Only record what I need to know and what I'am not so familar with.**
>
> <mark style="background: #FFF3A3A6;">In this Lab, should always remember what you are doing.</mark>

## 交叉编译

> 在一种计算机环境中运行的编译程序，能编译出在**另外一种环境**下运行的代码，我们就称这种编译器支持交叉编译。这个编译过程就叫交叉编译
> 交叉编译器在目标系统平台难以自我编译[^1]的时候非常有用。

实验所用的MOS内核就是通过<mark style="background: #ABF7F7A6;">mips-linux-gnu-gcc</mark>交叉编译器生成，然后运行在Gxemul模拟的硬件环境下的

> [!note] 顺带写了个查看本机GCC交叉编译器的脚本
>
> ```shell
> #! /bin/bash
> IFS = $'\n' # 指定换行符为分隔符的时候必须采用如下形式
> for line in $(cd /usr/bin && ls | grep "gcc")
> do
> 	$line -v 2>  "${line}" # 需要注意的是gcc-v查看版本信息居然默认是标准错误(长知识了)
> done
> ```

### 实验环境

> 在本节中，需要弄清楚实验内核mos究竟是如何运行在跳板机上的，为什么x86体系的结构能够编译出mips体系结构的内核，并且将其放入内存运行？

1. 实验make出的内核的硬件基础是<mark style="background: #FF5582A6;">MIPS R3000 CPU</mark>，再根据*《See MIPS Run Linux》*一书可以查阅得知，该CPU所采用的指令集架构是**MIPS I**(这块地方不是很确定，说不定是MIPS32?)
2. 实验所使用的跳板机是<mark style="background: #BBFABBA6;">x86-64</mark>架构，运行的操作系统是<mark style="background: #BBFABBA6;">Linux</mark>
3. 实验所采用的硬件模拟器是<mark style="background: #FFB86CA6;">Gxemul</mark>，我们所需的硬件环境就是它模拟出来的

### 启动流程

> 操作系统最重要的部分是操作系统内核，因为内核需要直接与硬件交互来管理各个硬件，从而利用硬件的功能为用户进程提供服务。为了启动操作系统，就需要将内核程序在计算机上运行起来，这就需要某个程序来<mark style="background: #D2B3FFA6;">启动</mark>整个计算机。

既然需要某个程序来启动计算机，之后还有让内核在计算机上运行，那为啥不干脆_让内核来启动计算机_呢？（两个愿望，一次满足hh）

你说得对，但是。。。一个程序要能够运行，其必须能够被 CPU 直接访问，所以不能放在磁盘上，因为 CPU 无法直接访问磁盘(启动之前_相关的硬件接口还没初始化呢_)，并且，内存RAM在断电后会丢失数据，那看来只能将内核放在非易失性内存ROM上了

> [!note] RAM和ROM
> RAM 是易失性内存，用于暂时存储正在处理的文件。 ROM 是非易失性内存，用于为电脑长久存储指令

看起来没问题，但实际上问题多的一批👇🏻

1. _空间太小_：这种 CPU 能直接访问的非易失性存储器的存储空间一般会映射到 CPU 可寻址空间的某个区域[^2]，这个是在硬件设计决定的。显然这个区域的大小是有限的，如果功能比较简单的操作系统还能够放在其中，对于较大的普通操作系统显然不够。
2. _OS限制_：内核在CPU加电后会直接启动，意味着_一台计算机只能使用一种操作系统_
3. 把特定硬件相关的代码全部放在操作系统中也不利于操作系统的移植工作

基于上述考虑，设计人员一般都会将硬件初始化的相关工作作为`bootloader`程序放在非易失存储器中，而将操作系统内核放在磁盘中。这样的做法可有效解决上述的问题

1. 解决了存储问题：将硬件初始化的相关工作从操作系统中抽出放在 bootloader 中实现，意味着通过这种方式实现了硬件启动和软件启动的分离。因此需要存储的硬件启动相关指令不需要很多，能够很容易地保存在容量较小的 ROM 或 FLASH 中。
2. 实现了多操作系统：`bootloader` 在硬件初始化完后，需要为软件启动（即操作系统内核的功能）做相应的准备，比如需要将内核镜像从存放它的存储器（比如磁盘）中读到 RAM 中。既然 `bootloader` 需要将内核镜像加载到内存中，那么它就能选择使用哪一个内核镜像进行加载，即实现多重开机的功能。使用 `bootloader` 后，我们就能够_在一个硬件上选择运行不同的操作系统_了
3. 软硬件分离：`bootloader` 主要负责硬件启动相关工作，同时操作系统内核则能够专注于软件启动以及对用户提供服务的工作，从而降低了硬件相关代码和软件相关代码的耦合度，有助于操作系统的移植。使用 `bootloader` 更清晰地划分了硬件启动和软件启动的边界，使操作系统与硬件交互的抽象层次提高了，从而简化了操作系统的开发和移植工作

> [!attention] 关于内存对齐和4GB寻址空间的问题
>
> 1. 首先要弄明白一点，操作系统中基本内存单位是**字节**
> 2. 总线为32位，所以一次CPU读取4字节，因此对应的指令地址一定是4字节对齐的(0,4,8,12......)
> 3. 这下好了，所有指令地址的末两位一定是0，这就解释了为什么26位的寻址实际可以搜索28位的地址空间
> 4. 32位CPU可以寻址2^32个单位空间，又因为基本单位是自己，所以寻址空间自然就是4GB了

#### 实际MIPS-OS启动流程

> 该部分内容暂时搁置

#### Gxemul仿真器启动流程

> GXemul（Gavare's eXperimental Emulator）是一款计算机架构模拟器，可以模拟所需硬件环境,例如本实验需要的 MIPS 架构下的 CPU，Gxemul非常稳定，可以让各种未经修改的操作系统运行就好像它们在真正的硬件上运行一样

操作系统的启动是一个非常复杂的过程(见👆🏻)。不过，由于 MOS 操作系统的目标是在GXemul仿真器上运行，这个过程被大大简化了

GXemul 仿真器支持直接加载 ELF 格式的内核，也就是说，GXemul已经提供了`bootloader`的引导（启动）功能。MOS 操作系统不需要再实现`bootloader`的功能。在 MOS 操作系统的运行第一行代码前，我们就已经拥有一个正常的程序运行环境，内存和一些外围设备都可以正常使用。

> [!note]
> 在Gxemul仿真器中，操作系统的启动流程被简化为**加载内核到内存**，再**跳转到内核入口**，这样启动就完成了

## ELF文件详解

> **ELF文件是一种用于可执行文件、目标文件、共享库和核心转储（`core dump`）的标准文件格式[^3]**
> 通俗的讲：由汇编器`as`和链接器`collect2(ld)`生成的文件都是ELF格式的文件

日常使用的ELF一般为一下三种👇🏻

1. **可重定位文件**（`relocatable file`） 它保存了一些可以和其他目标文件链接并生成可执行文件或者共享库的二进制代码和数据(_汇编器生成的.o文件_)
2. **可执行文件**（`excutable file`）它保存了适合直接加载到内存中执行的二进制程序
3. **共享库文件**（`shared object file`）一种特殊的可重定位目标文件，可以在加载或者运行时被动态的加载进内存并链接

### ELF文件结构

> 一个典型的ELF文件包括<mark style="background: #FFB86CA6;">ELF Header</mark>、<mark style="background: #BBFABBA6;">Section Header Table、Sections</mark>、<mark style="background: #ABF7F7A6;">Program Header Table、Segments</mark>五个部分，就如下图所示
> 注：本节所讲的ELF文件均为32bit

![[Pasted image 20230313123059.png]]
其中，段头表和节头表指向了相同的地方，这意味着两者只是程序数据的两种视图，其中节头表在组成_可重定向文件_时使用，而段头表则在组成_可执行文件_时使用

#### ELF Header

> ELF文件头，用于描述该ELF文件的基本信息，比如：魔数、体系结构、操作系统、段/节头表信息等等

```c
typedef unsigned short uint16_t;
typedef uint16_t Elf32_Half;
#define EI_NIDENT (16)
typedef struct {
	unsigned char e_ident[EI_NIDENT]; /* Magic number and other info */
	Elf32_Half e_type; /* Object file type */
	Elf32_Half e_machine; /* Architecture */
	Elf32_Word e_version; /* Object file version */
	Elf32_Addr e_entry; /* Entry point virtual address */
	Elf32_Off e_phoff; /* Program header table file offset */
	Elf32_Off e_shoff; /* Section header table file offset */
	Elf32_Word e_flags; /* Processor-specific flags */
	Elf32_Half e_ehsize; /* ELF header size in bytes */
	Elf32_Half e_phentsize; /* Program header table entry size */
	Elf32_Half e_phnum; /* Program header table entry count */
	Elf32_Half e_shentsize; /* Section header table entry size */
	Elf32_Half e_shnum; /* Section header table entry count */
	Elf32_Half e_shstrndx; /* Section header string table index */
} Elf32_Ehdr;
```

- e_ident:魔数，用于验证该文件是否为正常的ELF格式，格式不正确则拒绝加载
  ![[CleanShot 2023-03-13 at 12.58.20.png]]
  1. 1~4:为固定字节，分别对应ascii的Del、E、L、F，用于验证ELF格式
  2. 5:标识ELF文件是32位(01)还是64位(02)的
  3. 6:标识该ELF文件字节序是小端(01)还是大端(02)的
  4. 7:指示ELF文件的版本号，一般是01
  5. 8~end:未定义，均为00

##### 关于大、小端的理解

> 计算机硬件有两种<mark style="background: #FFB8EBA6;">储存数据</mark>的方式：大端字节序（big endian）和小端字节序（little endian）

>[!important]
> 该部分可能会在Lab1中出一道题，所以要尽量掌握

对于数值_0x2211_来说：高位字节是_0x22_，低位字节是_0x11_

- 大端字节序：高位字节在前，低位字节在后，就是人类读写数值的方法
- 小端字节序：低位字节在前，高位字节在后，即_0x1122_
![[Pasted image 20230313131513.png|非常形象的图片]]
![[Pasted image 20230313132207.png]]
>[!hint] So why little endian exists?
> 计算机电路先处理低位字节，效率比较高，因为计算都是从低位开始的

**计算机处理字节序的时候，不知道什么是高位字节，什么是低位字节。它只知道按顺序读取字节，先读第一个字节，再读第二个字节**

如果是大端字节序，先读到的就是高位字节，后读到的就是低位字节。小端字节序正好相反

>[!attention]
> **只有读取的时候，才必须区分字节序，其他情况都不用考虑**
> 只有在处理器读取数据的时候，需要区分字节顺序，因为它需要将数据根据大小端转换为正确的值（转换完成后就正常使用，不再考虑字节序的问题）

很容易可以得出<mark style="background: #ADCCFFA6;">大小端数据的转换公式</mark>👇🏻

```c
// 32位大端数据转换
x = buf[offset]<<24|buf[offset+1]<<16|buf[offset+2]<<8|buf[offset+3]
// 32位小端数据转换
x = buf[offset]|buf[offset+1]<<8|buf[offset+2]<<16|buf[offset+3]<<24
```
#### ELF

### 工具使用

#### gcc

![[Pasted image 20230313120332.png]]

#### readelf

#### objdump

## MIPS内存布局

## 参考资料

[楚权：ELF文件结构](http://chuquan.me/2018/05/21/elf-introduce/)
[阮一峰：理解字节序](https://www.ruanyifeng.com/blog/2016/11/byte-order.html)

## footnote

[^1]: 当目标平台还没有能够自我编译程序之前都需要通过交叉编译来生成目标程序的代码。

[^2]: 像32位的MIPS最大只能寻址4G

[^3]: 转载自维基百科
