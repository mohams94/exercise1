
clean:
	make -C quartus clean
	make -C software clean

submission:
	tar -cvzf submission.tar.gz Makefile rpa_shell.py quartus software vhdl
