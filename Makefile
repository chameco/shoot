SRCS = $(foreach file,$(wildcard lib/*),$(notdir $(file)))
BUILD_DIR = build
OBJS = $(addprefix $(BUILD_DIR)/, $(SRCS:.scm=.o))

vpath %.scm lib

.PHONY: all directories clean

all: directories shoot

directories: $(BUILD_DIR)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(BUILD_DIR)/%.o: %.scm
	csc -o $@ -c $<

shoot: $(BUILD_DIR)/shoot.o $(OBJS)
	csc -Wl,-lfftw3  $^ -o $@

clean:
	rm $(BUILD_DIR)/*.o
