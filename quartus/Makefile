

PROJECT_NAME=gettoknow

LOG_FILE=BUILD_$(shell date '+%d.%m.%y-%H_%M_%S').log
PROJECT_DIR=$(shell pwd)
OUTPUT_DIR=$(PROJECT_DIR)/$(PROJECT_NAME)
SOPC_INFO_FILE=$(PROJECT_NAME).sopcinfo
QSYS_FILE=$(PROJECT_NAME).qsys

ifeq ($(shell quartus_sh --version | grep -c Lite),1)
SOF_FILE=output_files/$(PROJECT_NAME)_time_limited.sof
else
SOF_FILE=output_files/$(PROJECT_NAME).sof
endif

RPA_SHELL=../rpa_shell.py
NIOS2_CMD_SHELL=$$(dirname $$(which quartus))/../../nios2eds/nios2_command_shell.sh

all: $(SOF_FILE)

quartus: $(SOF_FILE)

# starts the quartus GUI and loads the quartus project
quartus_gui:
	quartus --64bit $(PROJECT_NAME).qpf &

# starts the Platform Designer GUI and loads the qsys project
qsys_gui:
	$(NIOS2_CMD_SHELL) qsys-edit $(PROJECT_NAME).qsys &


$(SOF_FILE): $(QSYS_FILE) $(PROJECT_NAME).qsf $(PROJECT_NAME).qpf
	@echo ""
	@echo "---------------------------------------------" >> $(LOG_FILE)
	@echo "-                  QUARTUS                  -" >> $(LOG_FILE)
	@echo "---------------------------------------------" >> $(LOG_FILE)
	quartus_sh --flow compile $(PROJECT_NAME) 2>&1 | tee -a $(LOG_FILE) | (grep -E "^Warning|^Error|^Critical" || true)
	@echo "---------------------------------------------" 
	@echo "--      Errors and Warnings Overview        -"
	@echo "--    (for more details see build log)      -"
	@echo "---------------------------------------------"
	@cat $(LOG_FILE)  | grep -e "^Warning [\(][0-9]*[\)]:" || true
	@cat $(LOG_FILE)  | grep -e "^Critical Warning [\(][0-9]*[\)]:" || true
	@cat $(LOG_FILE)  | grep -e "^Error [\(][0-9]*[\)]:" || true
	
download:
	quartus_pgm -m jtag -o"p;$(SOF_FILE)"

remote_download:
	$(RPA_SHELL) -p $(SOF_FILE) --no-master -n

clean:
	rm -f $(PROJECT_NAME).sopcinfo
	rm -f $(PROJECT_NAME).html
	rm -f $(PROJECT_NAME).cmp
	rm -f *.rpt
	rm -f *.qws
	rm -fr $(OUTPUT_DIR)
	rm -fr output_files
	rm -fr db
	rm -f *.bsf
	rm -f *.dpf
	rm -f *.srf
	rm -fr incremental_db
	rm -f *.jdi
	rm -f *.html
	rm -f *.smsg
	rm -f *.summary
	rm -f *.qdf


.PHONY: qsys_gui
.PHONY: quartus
.PHONY: quartus_gui
.PHONY: download
.PHONY: clean

