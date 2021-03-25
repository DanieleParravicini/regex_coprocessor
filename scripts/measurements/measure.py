
import csv
import os 
import argparse
import sys
from   tqdm import tqdm

class regular_expression_measurer():
	def __init__(self, name):
		super().__init__()
		self.name = name

	def get_name(self):
		return self.name

	def execute(self, regex, string, O1=True, no_prefix=True, no_postfix=True, debug=False):
		raise NotImplementedError()

class re2copro_measurer(regular_expression_measurer):
	def __init__(self, bitstream_filepath, copro_not_check, frontend='pythonre'):
		super().__init__("re2copro[cc]")
		self.bitstream_filepath = bitstream_filepath
		self.copro_not_check    = copro_not_check
		self.frontend           = frontend
		import sys
		sys.path.append('../driver')
		import re2_driver
		import pynq
		from pynq import Overlay
		self.re2_coprocessor = Overlay(self.bitstream_filepath)
		
	
	def execute(self, regex, string, O1=True, no_prefix=True, no_postfix=True, debug=False):
		
		self.re2_coprocessor.cicero_core_0.reset()
		#freq                = 90_000_000
		if debug:
			print('string', string, ' regex:',regex)

		has_accepted = self.re2_coprocessor.cicero_core_0.compile_and_run(regex, string, no_prefix=no_prefix,no_postfix=no_postfix, O1=O1 , double_check=(not self.copro_not_check), frontend=self.frontend)
		cc_number 	 = self.re2_coprocessor.cicero_core_0.read_elapsed_clock_cycles()
		if debug:
			print('status:', self.re2_coprocessor.cicero_core_0.get_status(),
			'time re2coprocessor', cc_number, 'clock', 'cycles' if cc_number > 1 else 'cycle')
		return cc_number

class re2copro_compiler_size_measurer(regular_expression_measurer):
	def __init__(self, O1=True):
		super().__init__("re2copro_compiler_size "+("optimized" if O1 else "unoptimized")+ " [instructions]")

		self.optimize  = O1

	def execute(self, regex, string, O1=True, no_prefix=True, no_postfix=True, debug=False):
		import timeit
		
		#   O1 override
		O1 = self.optimize 
		import sys
		sys.path.append('../../re2compiler')
		import re2compiler
		code = re2compiler.compile(data=regex, O1=O1, no_prefix=no_prefix, no_postfix=no_postfix, o=None, frontend=args.format)
		
		
		return len(code.splitlines())

class re2copro_compiler_measurer(regular_expression_measurer):
	def __init__(self, num_times=100, O1=True): #100 for I5, ULTRA. 80 for PYNQ.
		super().__init__("re2copro_compiler[ns]")
		self.num_times = num_times
		self.optimize  = O1

	def execute(self, regex, string, O1=True, no_prefix=True, no_postfix=True, debug=False):
		import timeit

		O1 = self.optimize and O1
		execute_code = f"code = re2compiler.compile(data='{regex}', O1={O1}, no_prefix={no_prefix}, no_postfix={no_postfix}, o=None, frontend={args.format})"
		prepare_code = "import sys;sys.path.append('../../re2compiler');import re2compiler"
		
		secs = timeit.repeat(execute_code, prepare_code  ,number=self.num_times)
		if debug:
			print(secs)
		return (sum(secs)/len(secs))/self.num_times*1_000_000_000
	

class re_measurer(regular_expression_measurer):
	def __init__(self):
		super().__init__("re python[ns]")

	def execute(self, regex, string, O1=True, no_prefix=True, no_postfix=True, debug=False):
		import test_re
		min_time_re = test_re.time_no_prefix_match(r, line, perf_counter=True)
		if debug:
			print('minimum time', min_time_re, 'ns')
		return min_time_re

class RESULT_measurer(regular_expression_measurer):
	def __init__(self):
		super().__init__("RESULT")

	def execute(self, regex, string, O1=True, no_prefix=True, no_postfix=True, debug=False):
		import sys
		sys.path.append('../../re2compiler')
		import golden_model
		golden_model_res = golden_model.get_golden_model_result(regex, string, no_prefix=no_prefix, no_postfix=no_postfix,frontend=args.format)
		
		return golden_model_res


class emulated_re2_copro_asap_measurer(regular_expression_measurer):
	def __init__(self):
		super().__init__("emulated_re2copro_asap[cc]")
	
	def execute(self, regex, string, O1=True, no_prefix=True, no_postfix=True, debug=False):
		import sys
		sys.path.append('../../re2compiler')
		import emulate_execution
		cc = emulate_execution.cc_asap_no_prefix_match(r, line, perf_counter=True)
		if debug:
			print('minimum cc', cc)
		return cc


class emulated_re2_copro_measurer(regular_expression_measurer):
	def __init__(self):
		super().__init__("emulated_re2copro[cc]")

	
	def execute(self, regex, string, O1=True, no_prefix=True, no_postfix=True, debug=False):
		import sys
		sys.path.append('../../re2compiler')
		import emulate_execution
		cc = emulate_execution.cc_no_prefix_match(r, line)
		if debug:
			print('minimum cc', cc)
		return cc

class cmd_measurer(regular_expression_measurer):
	def __init__(self, name, program, batch_length=50, num_of_batches=10):
		super().__init__(name)
		self.program        = program
		self.batch_length   = batch_length
		self.num_of_batches = num_of_batches

	def execute(self, regex, string, O1=True, no_prefix=True, no_postfix=True, debug=False):
		res = [ self._execute(regex, string, O1=O1, no_prefix=no_prefix, no_postfix=no_postfix, debug=debug) for i in range(self.num_of_batches)]
		return sum(res)/len(res)

	def _execute(self, regex, string, O1=True, no_prefix=True, no_postfix=True, debug=False):
		from subprocess import run, CalledProcessError, PIPE
		num_times   = self.batch_length
		
		regex = to_supported_regex(regex, no_prefix, no_postfix)

		arguments   = f"time -p {self.program} \"{regex}\" \"{string}\" {num_times}"

		if sys.version_info[0] > 4 or (sys.version_info[0] == 3 and sys.version_info[1] >= 7):
			sub = run(arguments, capture_output=True, shell=True, check=False)
		else:
			sub = run(arguments,                      shell=True, check=False, stdout=PIPE, stderr=PIPE)

		if(sub.returncode != 0):
			if(sub.returncode ==1): 
				pass #grep returns an error code to signal a non-match
			else:
				print("error!")
				print('out->', sub.stdout)
				print('err->', sub.stderr)
				exit(sub.returncode)

		import re

		stderr = (sub.stderr.decode())
		
		res     = re.findall('real (\d+\.\d+)\nuser (\d+\.\d+)\nsys (\d+\.\d+)\n', stderr)
		if debug: 
			print('err->',type(sub.stderr), sub.stderr)
			print(len(res), res)

		if len(res) <1 or  (len(res)> 0 and len(res[0]) < 3) :
			exit(1)
		real    = float(res[0][0])
		user    = float(res[0][1])
		system  = float(res[0][2])

		return user*1_000_000_000/num_times

def to_supported_regex(regex, no_prefix, no_postfix):
	import sys
	sys.path.append('../../re2compiler')
	from helper import normalize_regex_input, pcre_to_python

	if args.format == 'pcre':
		regex = pcre_to_python(regex)
	regex = normalize_regex_input(regex)

	if no_prefix and regex[0:1] !='^(':
			regex = '^('+ regex + ')'

	if no_postfix and regex[-2:] !=')$':
			regex = '(' + regex + ')$'
	return regex	

class grep_measurer(cmd_measurer):
	def __init__(self, batch_length=50      , num_of_batches=10):
		super().__init__("grep", "./test_grep.sh", batch_length=batch_length, num_of_batches=num_of_batches )

class re2_measurer(cmd_measurer):
	def __init__(self, batch_length=50 , num_of_batches=20):
		super().__init__("re2", "./test_re2.o" , batch_length=batch_length, num_of_batches=num_of_batches )

class re2_chrono_measurer(regular_expression_measurer):
	def __init__(self, batch_length=50 ): #80_000 i5, 30_000 ULTRA, 1_000 PYNQ
		super().__init__(["[ re2_chrono_exe [ns]","re2_chrono_compile[ns]" ])
		self.batch_length 	= batch_length

	def execute(self, regex, string, O1=True, no_prefix=True, no_postfix=True, debug=False):
		from subprocess import run, CalledProcessError, PIPE
		num_times   = self.batch_length
		tmppath = 'tmpfile'
		with open(tmppath, 'wb') as tmp:
			tmp.write(string)

		regex = to_supported_regex(regex, no_prefix, no_postfix)
		arguments   = f"./test_re2_chrono.o \"{regex}\" \"{tmppath}\" {num_times}"

		if sys.version_info[0] > 4 or (sys.version_info[0] == 3 and sys.version_info[1] >= 7):
			sub = run(arguments, capture_output=True, shell=True, check=False)
		else:
			sub = run(arguments,                      shell=True, check=False, stdout=PIPE, stderr=PIPE)

		if(sub.returncode != 0):
			if(sub.returncode ==1): 
				pass #grep returns an error code to signal a non-match
			else:
				print("error!")
				print('out->', sub.stdout)
				print('err->', sub.stderr)
				exit(sub.returncode)

		import re

		stdout = sub.stdout.decode()
		
		res     = re.findall('Execution \d+ iterations?: avg time taken (\d+\.\d+)', stdout)

		if debug: 
			print('stdout->',type(sub.stdout), sub.stdout)
			print(len(res), res)

		if len(res) <1 or  (len(res)> 0 and len(res[0]) < 1) :
			exit(1)
		exec    = float(res[0])
		if debug:
			print(exec)

		res     = re.findall('Compilation \d+ iterations?: avg time taken (\d+\.\d+)', stdout)

		if debug: 
			print('stdout->',type(sub.stdout), sub.stdout)
			print(len(res), res)

		if len(res) <1 or  (len(res)> 0 and len(res[0]) < 1) :
			exit(1)

		compilation    = float(res[0])
		if debug:
			print(compilation)

		return [exec, compilation]


arg_parser = argparse.ArgumentParser(description='test regular expression matching')
arg_parser.add_argument('-maxstrlen'		, type=int , help='max length of string. to restrict string size'	                                                                	   , default=1024)
arg_parser.add_argument('-startstr'		    , type=int , help='index first str. to restrict num of strings'	                                                                		   , default=0   )
arg_parser.add_argument('-endstr'		    , type=int , help='index end string. to restrict num of strings'	                                                            		   , default=100)
arg_parser.add_argument('-startreg'		    , type=int , help='index first reg.to restrict num of regexp'	                                                                		   , default=0   )
arg_parser.add_argument('-endreg'		    , type=int , help='index end reg.to restrict num of regexp'		                                                                		   , default=100)
arg_parser.add_argument('-py'		                   , help='measure time taken by python re module'                   									, action='store_true'      , default=False)
arg_parser.add_argument('-copro'		               , help='measure clock cycles taken by copro. you have to look at -bitstream and -do_not_optimize'    , action='store_true'      , default=False)
arg_parser.add_argument('-coprocompiler'		       , help='measure time taken by copro compiler. you have to look at -do_not_optimize'                  , action='store_true'      , default=False)
arg_parser.add_argument('-compareCodeSize'		       , help='compare code size generated by optimized an unoptimized copro compiler.'                     , action='store_true'      , default=False)
arg_parser.add_argument('-simre2coproasap'		       , help='measure clock cycles taken by emulated re2copro.'        	 								, action='store_true'	   , default=False)
arg_parser.add_argument('-simre2copro'	               , help='measure clock cycles taken by emulated re2copro.'         									, action='store_true'	   , default=False)
arg_parser.add_argument('-re2'	                       , help='measure time taken by re2 using time.'                               						, action='store_true'      , default=False)
arg_parser.add_argument('-re2chrono'                   , help='measure time taken by re2 using chrono (distinguished between match and "compilation").'     , action='store_true'      , default=False)
arg_parser.add_argument('-grep'	                       , help='measure time taken by grep using time.'                              					    , action='store_true'      , default=False)
arg_parser.add_argument('-strfile'		    , type=str , help='file containing strings'  	                                        					    						   , default='protomata.input')
arg_parser.add_argument('-regfile'		    , type=str , help='file containing regular expressions'    	                            					    						   , default='protomata.regex'  )
arg_parser.add_argument('-bitstream'		, type=str , help='only for copro: coprocessor bitstream file'    	                                                    				   , default='')
arg_parser.add_argument('-copro_not_check'             , help='only for copro:disable check against a golden model(python re).'     						,action='store_true' 	   , default=False)
arg_parser.add_argument('-do_not_optimize'	           , help='only for copro and coprocompiler: do not optimize recopro code'      						,action='store_true'       , default=False)
arg_parser.add_argument('-debug'	                   , help='execute in debug mode'                                    									,action='store_true'       , default=False)
arg_parser.add_argument('-skipException'	           , help='skip exceptions'                                    									        ,action='store_true'       , default=False)
arg_parser.add_argument('-format'	        , type=str , help='regex input format'                                    									                               , default='pythonre')
args = arg_parser.parse_args()

optimize_str = "" if args.do_not_optimize else '_O1' 
bitstream_filename = ""  if not args.copro else os.path.basename(args.bitstream)[:-4]

#any program and coprocessors have a specific method
# to measure the time taken to complete a match.
# These methods are encapsulated into an instance of measurer subclass,
# which expose a method(execute()) to measure time required to match.  
# measurer_list is filled by measurer depending on user requests.
measurer_list = [RESULT_measurer()]
if args.copro:
	measurer_list.append(re2copro_measurer(args.bitstream, args.copro_not_check, args.format))
if args.coprocompiler:
	measurer_list.append(re2copro_compiler_measurer())
if args.compareCodeSize:
	measurer_list.append(re2copro_compiler_size_measurer(O1=False))
	measurer_list.append(re2copro_compiler_size_measurer(O1=True))
if args.py:
	measurer_list.append(re_measurer())
if args.simre2coproasap:
	measurer_list.append(emulated_re2_copro_asap_measurer())
if args.simre2copro:
	measurer_list.append(emulated_re2_copro_measurer())
if args.re2:
	measurer_list.append(re2_measurer())
if args.re2chrono:
	measurer_list.append(re2_chrono_measurer())
if args.grep:
	measurer_list.append(grep_measurer())
str_lines   = []
#read string file
with open(args.strfile, 'rb') as f:
	str_lines = f.readlines()[args.startstr:args.endstr]
	#str_lines = f.read().split(b'\n')[args.startstr:args.endstr]
	str_lines = list(map(lambda x: x[0:args.maxstrlen],str_lines))
regex_lines = []
#open regex file 
with open(args.regfile, 'r') as f:
	regex_lines = f.readlines()[args.startreg:args.endreg]

total_number_of_executions = len(str_lines)*len(regex_lines)*len(measurer_list)
progress_bar               = tqdm(total=total_number_of_executions)

#open log file
with open(f'measure_{bitstream_filename}{optimize_str}.csv', 'w', newline='') as csvfile:
	fout = csv.writer(csvfile, delimiter=',', quoting=csv.QUOTE_MINIMAL)
	#foreach string 
	for l_number, line in enumerate(str_lines):
		#print('len', len(line),'->', bytes(line,'utf-8'))
		#eliminate end of line
		line = line[:-1]
		#write in csv current string and caption
		fout.writerow(['string', line, '', ''])
		names = []
		for e in measurer_list:
			if isinstance(e.get_name(), list):
				names += [*e.get_name()]
			else:
				names.append(e.get_name())
		fout.writerow(['regex', *names])
		
		#foreach regex
		for r_number, r in enumerate(regex_lines):
			#result todo: report regex match result.
			#eliminate end of line from regex
			r            = r[:-1]
			results      = [ ]
			
			for e_number, e in enumerate(measurer_list):
				
				
				try:
					result = None
					result = e.execute(regex=r, string=line, no_postfix = False, no_prefix=False, O1=True, debug=args.debug )   
				except Exception as exc:
					print('error while executing regex', r,'\nstring [', len(line), 'chars]', line, exc)
					#if not args.skipException:
					raise exc
				   
				progress_bar.update(1)
				
				if isinstance(result, list):
					results +=[*result]
				else:
					results.append(result)
			fout.writerow([r,  *results ])
					



