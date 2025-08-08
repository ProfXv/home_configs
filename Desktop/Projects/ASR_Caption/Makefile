# Makefile for ASR Caption with GTK GUI

# --- Compiler and Flags ---
CC = gcc

# --- Directories ---
DIR_ROOT = .
DIR_INC = $(DIR_ROOT)/include
DIR_LIB = $(DIR_ROOT)/libs
DIR_SAMPLE_SRC = $(DIR_ROOT)/samples/iat_online_record_sample

# --- Target ---
TARGET_NAME	= ASRCaption
# Compile to user's local bin directory
TARGET_DIR = $(HOME)/.local/bin
TARGET = $(TARGET_DIR)/$(TARGET_NAME)

# --- GTK Configuration ---
GTK_CFLAGS   = $(shell pkg-config --cflags gtk4)
GTK_LDFLAGS  = $(shell pkg-config --libs gtk4)

# --- Flags ---
# CFLAGS for C files
CFLAGS = -g -Wall -fPIC $(GTK_CFLAGS) -I$(DIR_INC) -I$(DIR_SAMPLE_SRC) -I$(DIR_ROOT)

# Linker Flags
ifeq ($(LINUX64),)
	LINUX_ARCH=x64
else
	LINUX_ARCH=x64
endif
LDFLAGS := -L$(DIR_LIB)/$(LINUX_ARCH)
LDFLAGS += -lmsc -lrt -ldl -lpthread -lasound
LDFLAGS += $(GTK_LDFLAGS)

# --- Source Files ---
C_SRCS = main.c gui.c
C_SAMPLE_SRCS = iat_online_record_sample.c speech_recognizer.c linuxrec.c

# --- Object Files ---
C_OBJS = $(C_SRCS:.c=.o)
C_SAMPLE_OBJS = $(C_SAMPLE_SRCS:.c=.o)
OBJECTS = $(C_OBJS) $(C_SAMPLE_OBJS)

# --- Rules ---

all: $(TARGET)

$(TARGET): $(OBJECTS)
	@echo "--- Linking ---"
	@mkdir -p $(TARGET_DIR)
	$(CC) $(OBJECTS) -o $@ $(LDFLAGS)
	@echo "Build finished. Executable is at $(TARGET)"

# --- Compilation Rules ---

# Rule for C files
%.o: %.c
	$(CC) -c $(CFLAGS) $< -o $@

# Explicit rules for sample C files to handle their location
iat_online_record_sample.o: $(DIR_SAMPLE_SRC)/iat_online_record_sample.c
	$(CC) -c $(CFLAGS) $< -o $@

speech_recognizer.o: $(DIR_SAMPLE_SRC)/speech_recognizer.c
	$(CC) -c $(CFLAGS) $< -o $@

linuxrec.o: $(DIR_SAMPLE_SRC)/linuxrec.c
	$(CC) -c $(CFLAGS) $< -o $@

# --- Cleanup ---
clean:
	@echo "--- Cleaning ---"
	@rm -f *.o $(TARGET)
	@# Also clean the old target if it exists
	@rm -f $(DIR_ROOT)/bin/ASRCaption

.PHONY: all clean