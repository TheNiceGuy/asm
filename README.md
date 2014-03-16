Assembly Language
=================

My personal assembly language practices files.


Testing
-------
You can use the command:
	./assemble <file>

Where <file> is actually the name of the file without the extension. This small script will compile, link, execute, return the exit code and remove the 
temporary file. These are the commands it does and order:

	as src/<file>.asm -o src/<file>.o
	ld src/<file>.o -o bin/<file>
	./bin/<file> <arg1> <arg2> <arg3> <argN>
	echo $?
	rm src/<file>.o
