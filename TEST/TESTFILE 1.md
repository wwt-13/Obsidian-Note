# 1
> 测测<font color="red">测测</font>

# 2
![[test.sql]]

> [!NOTE] Title
> Contents
## 测试
![[TESTFILE#^5aa152|hello]]
#测试 
#tracking 
![[TESTFILE#^e8b1cb]]
```makefile
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

# TITLE1
## TITLE2
## title3
#### title4
##### title5
###### title6
**这是一段粗体文本**
*这是一段斜体文本*
<u>这是一段下划线</u>



