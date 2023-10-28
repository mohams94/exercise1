#!/usr/bin/env python3

import random
from bitstring import Bits
import subprocess
import select
import os
import sys
import threading
import time

dir_path = os.path.dirname(os.path.realpath(__file__))

sys.path.append(dir_path + '/../../')
from rpa_shell import load_cfg, rpa_server, cfg_file_path, RPAClient, Status, RPAConnection

def RandomFix16Values(value_range, count):
	value_range_int = [int(value_range[0]*pow(2,16)),int(value_range[1]*pow(2,16))]
	values = []

	for i in range(0,count):
		values.append(random.randint(value_range_int[0], value_range_int[1]))

	return values

def Hex32ToInt(hexstring):
	x = int(hexstring, 16)
	if(x > 0x7fffffff):
		x = -(0xffffffff - x + 1)
	return x

def IntToHex32(i):
	b = Bits(int=i, length=32)
	return '0x' + str(b.hex)

def ToFloat(values):
	fvalues = []

	for v in values:
		fvalues.append(float(v)*(1/2**16))

	return fvalues

def GenerateInputFile(x):
	assert len(x) % 3 == 0
	output = ""
	output += "process " +str(int(len(x)/3))+"\n"
	for i in x:
		output += IntToHex32(i) + "\n"

	output += "check_speed\n"
	output += "exit\n" #don't forget the new line
	return output

def RunRef():
	output_values = []
	output_lines = os.popen("cat instructions | "+dir_path+"/ref").read().split()

	for line in output_lines[:-1]: 
		output_values.append(Hex32ToInt(line))

	return (output_values, int(output_lines[-1], 0))

def RunNios():
	output_values = []
	output_lines = os.popen("nios2-terminal -q < instructions").read().split()

	for line in output_lines[:-1]:
		output_values.append(Hex32ToInt(line))

	return (output_values, int(output_lines[-1], 0))

def RunRemote():
	cfg = load_cfg(cfg_file_path)
	hw_output = ''
	has_place = threading.Barrier(2)

	check_done = threading.Lock()
	check_done.acquire(blocking=False)

	def download_sof():
		""" Create new rpa-master connection if necessary then run quartus_pgm
			and keep it open (necessary for intelFPGA-light with IP-cores)
		"""

		nonlocal hw_output
		host_acquired = False

		c = RPAClient(rpa_server, cfg["username"], identity=cfg["identity"])
		status = c.ConnectionStatus()
		if status == Status.ASSIGNED:
			connection = c.Connection
		elif status == Status.NOT_ASSIGNED:
			c.RequestHost()
			# TODO: if acquiring host takes long (no error) this thread
			# will prevent the process to stop when the timeout is
			# reached in main thread
			c.WaitForHost()
			host_acquired = True
			connection = c.Connection
		else:
			print("Failed to lock place")
			exit(1)

		# sync with main thread that rpa-lock was successful
		try:
			has_place.wait()
		except threading.BrokenBarrierError:
			if host_acquired:
				c.ReleaseHost()
			exit(1)


		ssh_cmd = connection.CreateSSHCommand('quartus_pgm -mjtag \'-o"p;.rpa_shell/hw.sof"\'', ssh_args='-tt')
		print('-- Programming Hardware --')
		p = subprocess.Popen(ssh_cmd, shell=True, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)

		while True:
			readable, writable, error = select.select([p.stdout], [], [], 0.5)
			if readable:
				outp = p.stdout.read1(4096).decode()
				print(outp, end='')
				hw_output += outp
			else: # timeout, no data available
				pass

			if check_done.acquire(blocking=False):
				p.terminate()
				if host_acquired:
					c.ReleaseHost()
				break


	output_values = []

	client = RPAClient(rpa_server, cfg["username"], identity=cfg["identity"])

	t = threading.Thread(target=download_sof)
	t.start()

	# check if downloader was able to get seat-lock
	try:
		has_place.wait(timeout=10)
	except threading.BrokenBarrierError:
		print('Waiting for a seat took too long, exiting!')
		check_done.release()
		exit(1)

	time_wait = 0.5
	timeout = 20
	time_waited = 0
	while True:
		if 'Error' in hw_output:
			print()
			print('Another program is using the jtag connection already')
			print('Most likely there is still an instance of nios2-terminal or quartus_pgm running')
			print("If this is not intended, run './rpa_shell.py \"killall quartus_pgm\"'")
			print("or './rpa_shell.py \"killall nios2-terminal\"'")
			check_done.release()
			exit(1)
		elif 'Ended Programmer' in hw_output:
			print()
			print('Hardware has been programmend sucessfully!')
			break

		time.sleep(time_wait)
		time_waited += time_wait
		if time_waited > timeout:
			print()
			print('Took too long to to program hardware, exiting!')
			check_done.release()
			exit(1)
		
	# check for failure
	status = client.ConnectionStatus()
	if status != Status.ASSIGNED:
		print("No master session established!")
		print("Most likely you had another rpa-master connection open which just timed out")
		check_done.release()
		exit(1)

	connection = client.Connection
	ssh_cmd = connection.CreateSSHCommand("/opt/quartus_18.1/nios2eds/nios2_command_shell.sh nios2-download -g .rpa_shell/fw.elf")
	p = subprocess.run(ssh_cmd, shell=True)


	ssh_cmd = connection.CreateSSHCommand("/opt/quartus_18.1/nios2eds/nios2_command_shell.sh nios2-terminal -q")
	output_lines = ''
	with open(dir_path + "/../instructions") as instr_file:
		p = subprocess.run(ssh_cmd, shell=True, input=instr_file.read().encode(), stdout=subprocess.PIPE)
		output_lines = p.stdout.decode().splitlines()

	# checking complete, stop quartus_pgm
	check_done.release()

	for line in output_lines[:-1]:
		output_values.append(Hex32ToInt(line))

	return (output_values, int(output_lines[-1], 0))





value_range = [-32,31]
x = RandomFix16Values(value_range, 32*3)

with open("instructions", 'w') as instructions:
	instructions.write(GenerateInputFile(x))


(out_ref, pc_runtime) = RunRef()

if(len(sys.argv)>1 and sys.argv[1]=="remote"):
	(out_nios, nios_runtime) = RunRemote()
else:
	(out_nios, nios_runtime) = RunNios()



print("input".rjust(10, ' ') + "  " + "Nios II".rjust(10, ' ') + "  " + "Ref".rjust(10, ' '))

test_passed = True

for i in range(0, len(out_ref)):
	val_nios = out_nios[i]
	val_ref = out_ref[i]
	
	int_error = abs(val_nios - val_ref)

	line = IntToHex32(x[i]) + "  " + IntToHex32(val_nios) + "  " + IntToHex32(val_ref) 
	
	if (int_error > 1):
		line += " <-- ERROR (inaccuracy)!"
		test_passed = False
	
	print(line)
	if(i%3==2):
		print('-')


if (test_passed):
	print(">>> value check PASSED <<<")
else:
	print(">>> value check FAILED <<<")


if (nios_runtime < 7000):
	print("runtime = " + str(nios_runtime) + " cycles")
	print(">>> speed check PASSED <<<")
else:
	print("Your solution is too slow! runtime = " + str(nios_runtime) +" cycles")
	print(">>> speed check FAILED <<<")

