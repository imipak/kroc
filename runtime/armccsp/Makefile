TARGET = armccsp.a
SOURCES = support.c kfunc.c kernel.c

CCHAIN = api-call-chain-armccsp

CROSS_COMPILE = arm-linux-gnueabi-
CC = gcc-4.7
LD = ld
AR = ar

OBJS=$(SOURCES:%.c=%.o)
DEPS=$(OBJS:%.o=%.d)

# BASE points at where the EV3 sources are
# BASE = /home/frmb/research/ev3/ev3sources

# DEVKIT = $(BASE)/extra/linux-devkit/arm-none-linux-gnueabi
DEVKIT = /media/ev3dev_2_img
INCLUDES += -I.
# INCLUDES += -I$(DEVKIT)/usr/include/dbus-1.0
# INCLUDES += -I$(DEVKIT)/usr/lib/dbus-1.0/include
# INCLUDES += -I$(DEVKIT)/usr/include
# INCLUDES += -I$(DEVKIT)/usr/include/arm-linux-gnueabi
CFLAGS = -DPCASM $(INCLUDES) -O0 -Wall -fPIC -fomit-frame-pointer -fstack-usage
#LDFLAGS = -L$(DEVKIT)/usr/lib
#LDFLAGS = --shared
ARFLAGS = -r

all: $(TARGET) $(CCHAIN)

%.o: %.c
	$(CROSS_COMPILE)$(CC) $(CFLAGS) -c -MMD -MP -o $@ $<

$(TARGET): $(OBJS)
	$(CROSS_COMPILE)$(AR) $(ARFLAGS) $@ $(OBJS)

$(CCHAIN): $(TARGET) calltest.o
	./makecallchain.sh > $(CCHAIN)

.PHONY: clean
clean:
	rm -f $(OBJS) $(TARGET) $(DEPS) calltest.o $(CCHAIN)

-include $(DEPS)

