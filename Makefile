.PHONY: all clean build test sim

SRCDIR = ./src/rtl
OBJDIR = ./obj_dir
OBJS = 
TBDIR = ./test_bench
VERILATOR_TBDIR = $(TBDIR)/verilator
TBBENCHES = $(subst ) 
SRCS = decoder
SV_SRCS = $(patsubst %,$(SRCDIR)/%, $(patsubst %,%.sv,$(SRCS)))
TBS = $(patsubst %, tb_%, $(patsubst %.sv,%.cpp,$(SRCS)))
INC = -I$(SRCDIR)

define BUILD_VERILATOR
$(1): $(SRCDIR)/decoder.sv
	verilator $(INC) --cc $(SRCDIR)/$(1).sv --exe $(VERILATOR_TBDIR)/tb_$(1).cpp
	make -C $(OBJDIR) -f V$(1).mk
	./$(OBJDIR)/V$(1)
endef

$(foreach S, $(SRCS), $(eval $(call BUILD_VERILATOR,$(S))))

clean: 
	rm -rf ./obj_dir