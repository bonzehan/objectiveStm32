#=============================================================================#
# ARM makefile
#
# author: reymondo
# last change: 2012-03-04
#
# this makefile is based strongly on examples from: 
# http://www.freddiechopin.info/
# 
#=============================================================================#

#=============================================================================#
# toolchain configuration
#=============================================================================#

TOOLCHAIN = arm-none-eabi-

CXX = $(TOOLCHAIN)g++
CC = $(TOOLCHAIN)gcc
AS = $(TOOLCHAIN)gcc -x assembler-with-cpp
OBJCOPY = $(TOOLCHAIN)objcopy
OBJDUMP = $(TOOLCHAIN)objdump
SIZE = $(TOOLCHAIN)size
RM = rm -f

ST_LIB=.

#=============================================================================#
# project configuration
#=============================================================================#

# project name
PROJECT = objectiveStm32

# core type
CORE = cortex-m3

# linker script
LD_SCRIPT = ./stm32_flash.ld

# output folder (absolute or relative path, leave empty for in-tree compilation)
OUT_DIR = out

# ASM definitions
AS_DEFS =

# include directories (absolute or relative paths to additional folders with
# headers, current folder is always included)
INC_DIRS = Boards
INC_DIRS += Boards/boards
INC_DIRS += hdr
INC_DIRS += Boards/numberOfPorts
INC_DIRS += Gpio/inc
INC_DIRS += Rcc/inc
INC_DIRS += Usart/inc
INC_DIRS += Interface
INC_DIRS += $(ST_LIB)/Libraries/CMSIS/CM3/CoreSupport/

# library directories (absolute or relative paths to additional folders with
# libraries)
LIB_DIRS =

# libraries (additional libraries for linking, e.g. "-lm -lsome_name" to link
# math library libm.a and libsome_name.a)
LIBS =

# additional directories with source files (absolute or relative paths to
# folders with source files, current folder is always included)
SRC_DIRS = Boards
SRC_DIRS += Boards/boards
SRC_DIRS += hdr
SRC_DIRS += Boards/numberOfPorts
SRC_DIRS += Gpio/src
SRC_DIRS += Rcc/src
SRC_DIRS += Usart/src
SRC_DIRS += $(ST_LIB)/Libraries/CMSIS/CM3/CoreSupport/

# extension of C++ files
CXX_EXT = cpp

# wildcard for C++ source files (all files with CXX_EXT extension found in
# current folder and SRC_DIRS folders will be compiled and linked)
CXX_SRC = $(wildcard $(patsubst %, %/*.$(CXX_EXT), . $(SRC_DIRS)))

# extension of C files
C_EXT = c

# wildcard for C source files (all files with C_EXT extension found in current
# folder and SRC_DIRS folders will be compiled and linked)
C_SRC = $(wildcard $(patsubst %, %/*.$(C_EXT), . $(SRC_DIRS)))

# extension of ASM files
AS_EXT = S

# wildcard for ASM source files (all files with AS_EXT extension found in
# current folder and SRC_DIRS folders will be compiled and linked)
AS_SRC = $(wildcard $(patsubst %, %/*.$(AS_EXT), . $(SRC_DIRS)))

# optimization flags ("-O0" - no optimization, "-O1" - optimize, "-O2" -
# optimize even more, "-Os" - optimize for size or "-O3" - optimize yet more) 
OPTIMIZATION = -O0

# set to 1 to optimize size by removing unused code and data during link phase
REMOVE_UNUSED = 1

# set to 1 to compile and link additional code required for C++
USES_CXX = 1

# define warning options here
CXX_WARNINGS = -Wall -Wextra
C_WARNINGS = -Wall -Wextra

# C++ language standard ("c++98", "gnu++98" - default, "c++0x", "gnu++0x")
CXX_STD = gnu++98

# C language standard ("c89" / "iso9899:1990", "iso9899:199409",
# "c99" / "iso9899:1999", "gnu89" - default, "gnu99")
C_STD = gnu89

#=============================================================================#
# set the VPATH according to SRC_DIRS
#=============================================================================#

VPATH = $(SRC_DIRS)

#=============================================================================#
# when using output folder, append trailing slash to its name
#=============================================================================#

ifeq ($(strip $(OUT_DIR)), )
	OUT_DIR_F =
else
	OUT_DIR_F = $(strip $(OUT_DIR))/
endif

#=============================================================================#
# various compilation flags
#=============================================================================#
# ??? -adhlns="$@.lst" -c -fmessage-length=0 -mcpu=cortex-m3 -mthumb -g3 -gdwarf-2
# core flags
CORE_FLAGS = -mcpu=$(CORE) -mthumb

# flags for C++ compiler
CXX_FLAGS = -std=$(CXX_STD) -g -ggdb3 -fno-rtti -fno-exceptions -fverbose-asm -Wa,-ahlms=$(OUT_DIR_F)$(notdir $(<:.$(CXX_EXT)=.lst))

# flags for C compiler
C_FLAGS = -std=$(C_STD) -g -ggdb3 -fverbose-asm -Wa,-ahlms=$(OUT_DIR_F)$(notdir $(<:.$(C_EXT)=.lst))

# flags for assembler
AS_FLAGS = -g -ggdb3 -Wa,-amhls=$(OUT_DIR_F)$(notdir $(<:.$(AS_EXT)=.lst))

# flags for linker
LD_FLAGS = -T$(LD_SCRIPT) -g -Wl,-Map=$(OUT_DIR_F)$(PROJECT).map,--cref,--no-warn-mismatch

# process option for removing unused code
ifeq ($(REMOVE_UNUSED), 1)
	LD_FLAGS += -Wl,--gc-sections
	OPTIMIZATION += -ffunction-sections -fdata-sections
endif

# if __USES_CXX is defined for ASM then code for global/static constructors /
# destructors is compiled; if -nostartfiles option for linker is added then C++
# initialization / finalization code is not linked
ifeq ($(USES_CXX), 1)
	AS_DEFS += -D__USES_CXX
else
	LD_FLAGS += -nostartfiles
endif

#=============================================================================#
# do some formatting
#=============================================================================#

CXX_OBJS = $(addprefix $(OUT_DIR_F), $(notdir $(CXX_SRC:.$(CXX_EXT)=.o)))
C_OBJS = $(addprefix $(OUT_DIR_F), $(notdir $(C_SRC:.$(C_EXT)=.o)))
AS_OBJS = $(addprefix $(OUT_DIR_F), $(notdir $(AS_SRC:.$(AS_EXT)=.o)))
OBJS = $(AS_OBJS) $(C_OBJS) $(CXX_OBJS) $(USER_OBJS)
DEPS = $(OBJS:.o=.d)
INC_DIRS_F = -I. $(patsubst %, -I%, $(INC_DIRS))
LIB_DIRS_F = $(patsubst %, -L%, $(LIB_DIRS))

ELF = $(OUT_DIR_F)$(PROJECT).elf
HEX = $(OUT_DIR_F)$(PROJECT).hex
BIN = $(OUT_DIR_F)$(PROJECT).bin
LSS = $(OUT_DIR_F)$(PROJECT).lss
DMP = $(OUT_DIR_F)$(PROJECT).dmp

# format final flags for tools, request dependancies for C++, C and asm
CXX_FLAGS_F = $(CORE_FLAGS) $(OPTIMIZATION) $(CXX_WARNINGS) $(CXX_FLAGS)  $(CXX_DEFS) -MD -MP -MF $(OUT_DIR_F)$(@F:.o=.d) $(INC_DIRS_F)
C_FLAGS_F = $(CORE_FLAGS) $(OPTIMIZATION) $(C_WARNINGS) $(C_FLAGS) $(C_DEFS) -MD -MP -MF $(OUT_DIR_F)$(@F:.o=.d) $(INC_DIRS_F)
AS_FLAGS_F = $(CORE_FLAGS) $(AS_FLAGS) $(AS_DEFS) -MD -MP -MF $(OUT_DIR_F)$(@F:.o=.d) $(INC_DIRS_F)
LD_FLAGS_F = $(CORE_FLAGS) $(LD_FLAGS) $(LIB_DIRS_F)

#contents of output directory
GENERATED = $(wildcard $(patsubst %, $(OUT_DIR_F)*.%, bin d dmp elf hex lss lst map o))

# add board specific options
-include Make/boardConfig.mk

#=============================================================================#
# make all
# first, set TARGET variable used by boardConfig
#=============================================================================#
all : make_output_dir $(ELF) $(LSS) $(DMP) $(HEX) $(BIN) print_size

# make object files dependent on Makefile
$(OBJS) : Makefile
# make .elf file dependent on linker script
$(ELF) : $(LD_SCRIPT)

#-----------------------------------------------------------------------------#
# linking - objects -> elf
#-----------------------------------------------------------------------------#

$(ELF) : $(OBJS)
	@echo 'Linking target: $(ELF)'
	$(CXX) $(LD_FLAGS_F) $(OBJS) $(LIBS) -o $@
	@echo ' '

#-----------------------------------------------------------------------------#
# compiling - C++ source -> objects
#-----------------------------------------------------------------------------#

$(OUT_DIR_F)%.o : %.$(CXX_EXT)
	@echo 'Compiling file: $<'
	$(CXX) -c $(CXX_FLAGS_F) $< -o $@
	@echo ' '

#-----------------------------------------------------------------------------#
# compiling - C source -> objects
#-----------------------------------------------------------------------------#

$(OUT_DIR_F)%.o : %.$(C_EXT)
	@echo 'Compiling file: $<'
	$(CC) -c $(C_FLAGS_F) $< -o $@
	@echo ' '

#-----------------------------------------------------------------------------#
# assembling - ASM source -> objects
#-----------------------------------------------------------------------------#

$(OUT_DIR_F)%.o : %.$(AS_EXT)
	@echo 'Assembling file: $<'
	$(AS) -c $(AS_FLAGS_F) $< -o $@
	@echo ' '

#-----------------------------------------------------------------------------#
# memory images - elf -> hex, elf -> bin
#-----------------------------------------------------------------------------#

$(HEX) : $(ELF)
	@echo 'Creating IHEX image: $(HEX)'
	$(OBJCOPY) -O ihex $< $@
	@echo ' '

$(BIN) : $(ELF)
	@echo 'Creating binary image: $(BIN)'
	$(OBJCOPY) -O binary $< $@
	@echo ' '

#-----------------------------------------------------------------------------#
# memory dump - elf -> dmp
#-----------------------------------------------------------------------------#

$(DMP) : $(ELF)
	@echo 'Creating memory dump: $(DMP)'
	$(OBJDUMP) -x --syms $< > $@
	@echo ' '

#-----------------------------------------------------------------------------#
# extended listing - elf -> lss
#-----------------------------------------------------------------------------#

$(LSS) : $(ELF)
	@echo 'Creating extended listing: $(LSS)'
	$(OBJDUMP) -S $< > $@
	@echo ' '

#-----------------------------------------------------------------------------#
# print the size of the objects and the .elf file
#-----------------------------------------------------------------------------#

print_size :
	@echo 'Size of modules:'
	$(SIZE) -B -t --common $(OBJS) $(USER_OBJS)
	@echo ' '
	@echo 'Size of target .elf file:'
	$(SIZE) -B $(ELF)
	@echo ' '

#-----------------------------------------------------------------------------#
# create the desired output directory
#-----------------------------------------------------------------------------#

make_output_dir :
	$(shell mkdir $(OUT_DIR_F) 2>/dev/null)

#=============================================================================#
# make clean
#=============================================================================#

clean:
ifeq ($(strip $(OUT_DIR_F)), )
	@echo 'Removing all generated output files'
else
	@echo 'Removing all generated output files from output directory: $(OUT_DIR_F)'
endif
ifneq ($(strip $(GENERATED)), )
	$(RM) $(GENERATED)
else
	@echo 'Nothing to remove...'
endif

#=============================================================================#
# global exports
#=============================================================================#

.PHONY: all clean dependents

.SECONDARY:

# include dependancy files
-include $(DEPS)
