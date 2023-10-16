
# PROJECT_NAME must contain the name of the quartus project
PROJECT_NAME=gettoknow
SOPC_FILE=../quartus/$(PROJECT_NAME).sopcinfo

BSP_SETTINGS_FILE=./settings.bsp
BSP_DIR=./bsp
QUARTUS_PROJECT_DIR=../quartus
APPLICATION_BUILD_DIR=./build
APPLICATION_MAKEFILE=$(APPLICATION_BUILD_DIR)/Makefile 
ELF_FILE=$(APPLICATION_BUILD_DIR)/$(PROJECT_NAME).elf

#info: The application makefile automatically runs the bsp makefile
SRC_DIR=./src
NIOS2_APP_GEN_ARGS=--elf-name ${PROJECT_NAME}.elf --set APP_CFLAGS_OPTIMIZATION -Os --set OBJDUMP_INCLUDE_SOURCE 1 --src-rdir ${SRC_DIR}

NIOS2_CMD_SHELL=$$(dirname $$(which quartus))/../../nios2eds/nios2_command_shell.sh

RPA_SHELL=../rpa_shell.py
REMOTE_LAB_NIOS2_CMD_SHELL=/opt/quartus_18.1/nios2eds/nios2_command_shell.sh

ifeq ($(shell quartus_sh --version | grep -c Lite),1)
SOF_FILE=$(QUARTUS_PROJECT_DIR)/output_files/$(PROJECT_NAME)_time_limited.sof
else
SOF_FILE=$(QUARTUS_PROJECT_DIR)/output_files/$(PROJECT_NAME).sof
endif


all: $(ELF_FILE) 

$(APPLICATION_MAKEFILE): $(BSP_DIR) src/*
	$(NIOS2_CMD_SHELL) nios2-app-generate-makefile --app-dir ${APPLICATION_BUILD_DIR} --bsp-dir ${BSP_DIR} --set QUARTUS_PROJECT_DIR=${QUARTUS_PROJECT_DIR} ${NIOS2_APP_GEN_ARGS}
	

run: $(ELF_FILE) 
	$(NIOS2_CMD_SHELL) nios2-download -g $(ELF_FILE) && nios2-terminal

remote_run: $(ELF_FILE)
	$(RPA_SHELL) --scp $(ELF_FILE) .rpa_shell/fw.elf
	$(RPA_SHELL) --no-master "$(REMOTE_LAB_NIOS2_CMD_SHELL) nios2-download -g .rpa_shell/fw.elf && $(REMOTE_LAB_NIOS2_CMD_SHELL) nios2-terminal"

download: 
	$(NIOS2_CMD_SHELL) nios2-download -g $(ELF_FILE)

remote_download:
	$(RPA_SHELL) --scp $(ELF_FILE) .rpa_shell/fw.elf
	$(RPA_SHELL) --no-master "$(REMOTE_LAB_NIOS2_CMD_SHELL) nios2-download -g .rpa_shell/fw.elf"

remote_download_sof:
	$(RPA_SHELL) -p $(SOF_FILE) -n

term:
	$(NIOS2_CMD_SHELL) nios2-terminal

remote_term:
	$(RPA_SHELL) --no-master "$(REMOTE_LAB_NIOS2_CMD_SHELL) nios2-terminal"

edit_bsp:
	$(NIOS2_CMD_SHELL) nios2-bsp-editor &

$(ELF_FILE): $(APPLICATION_MAKEFILE)
	$(NIOS2_CMD_SHELL) make -C $(APPLICATION_BUILD_DIR)

$(BSP_DIR): $(SOPC_FILE) $(BSP_SETTINGS_FILE)
	echo $(NIOS2_CMD_SHELL)
	mkdir -p $(BSP_DIR)
	$(NIOS2_CMD_SHELL) nios2-bsp-update-settings --settings $(BSP_SETTINGS_FILE) --sopc $(SOPC_FILE)
	$(NIOS2_CMD_SHELL) nios2-bsp-generate-files --settings $(BSP_SETTINGS_FILE) --bsp-dir $(BSP_DIR)

check: $(ELF_FILE)
	make -C checker
	make clean_app all
	make download
	./checker/check.py

remote_check: $(ELF_FILE)
	make -C checker
	$(RPA_SHELL) --scp $(SOF_FILE) .rpa_shell/hw.sof
	$(RPA_SHELL) --scp $(ELF_FILE) .rpa_shell/fw.elf
	./checker/check.py remote

clean:
	rm -rf $(BSP_DIR)
	rm -rf $(APPLICATION_BUILD_DIR)
	make clean -C checker
	rm -f instructions
	rm -f remote_output

clean_app:
	rm -rf $(APPLICATION_BUILD_DIR)

.PHONY: edit_bsp
.PHONY: term
.PHONY: download
.PHONY: run

