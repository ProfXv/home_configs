# Makefile for ASR Caption with Qt GUI (Final MOC Flags Fix)

# --- Compiler and Flags ---
CXX = g++
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

# --- Qt Configuration ---
QT_CFLAGS   = $(shell pkg-config --cflags Qt5Widgets)
QT_LDFLAGS  = $(shell pkg-config --libs Qt5Widgets)
QT_MOC      = moc

# --- Flags ---
# CXXFLAGS for C++ files, contains all flags
CXXFLAGS = -g -Wall -fPIC $(QT_CFLAGS) -I$(DIR_INC) -I$(DIR_SAMPLE_SRC)
# MOC_FLAGS for the MOC tool, only needs -I (includes) and -D (defines)
MOC_FLAGS = $(filter -I% -D%, $(CXXFLAGS))
# CFLAGS for C files
CFLAGS = -g -Wall -I$(DIR_INC) -I$(DIR_SAMPLE_SRC)

# Linker Flags
ifeq ($(LINUX64),)
	LINUX_ARCH=x64
else
	LINUX_ARCH=x64
endif
LDFLAGS := -L$(DIR_LIB)/$(LINUX_ARCH)
LDFLAGS += -lmsc -lrt -ldl -lpthread -lasound
LDFLAGS += $(QT_LDFLAGS)

# --- Source Files ---
CPP_SRCS = main.cpp gui.cpp controller.cpp c_callbacks.cpp
C_SRC_FILES = iat_online_record_sample.c speech_recognizer.c linuxrec.c
MOC_HDRS = controller.h gui.h

# --- Generated Files ---
MOC_SRCS = $(MOC_HDRS:.h=.moc.cpp)
CPP_OBJS = $(CPP_SRCS:.cpp=.o)
C_OBJS = $(C_SRC_FILES:.c=.o)
MOC_OBJS = $(MOC_SRCS:.cpp=.o)
OBJECTS = $(CPP_OBJS) $(C_OBJS) $(MOC_OBJS)

# --- Rules ---

all: $(TARGET)

$(TARGET): $(OBJECTS)
	@echo "--- Linking ---"
	@mkdir -p $(TARGET_DIR)
	$(CXX) $(OBJECTS) -o $@ $(LDFLAGS)
	@echo "Build finished. Executable is at $(TARGET)"

# --- Compilation Rules ---

# Rule for C++ files
%.o: %.cpp
	$(CXX) -c $(CXXFLAGS) $< -o $@

# Rule for MOC-generated files, using the filtered MOC_FLAGS
%.moc.cpp: %.h
	$(QT_MOC) $(MOC_FLAGS) $< -o $@

# Explicit rules for C files
iat_online_record_sample.o: $(DIR_SAMPLE_SRC)/iat_online_record_sample.c
	$(CC) -c $(CFLAGS) $< -o $@

speech_recognizer.o: $(DIR_SAMPLE_SRC)/speech_recognizer.c
	$(CC) -c $(CFLAGS) $< -o $@

linuxrec.o: $(DIR_SAMPLE_SRC)/linuxrec.c
	$(CC) -c $(CFLAGS) $< -o $@

# --- Cleanup ---
clean:
	@echo "--- Cleaning ---"
	@rm -f *.o *.moc.cpp $(TARGET)
	@# Also clean the old target if it exists
	@rm -f $(DIR_ROOT)/bin/ASRCaption

.PHONY: all clean
