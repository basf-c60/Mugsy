Mugsy (Melbourne House, 1984) - SkoolKit disassembly

mugsy.skool / mugsy.ref   SkoolKit source (build: skool2html.py mugsy.skool mugsy.ref)
mugsy.ctl                 control file generated from the skool file
mugsy.asm                 assembler listing (skool2asm.py)
html/mugsy/index.html     the built HTML disassembly (Overview, Economics, VM, Variables, Pictures, Mugsy and The Hobbit, Bugs, Trivia)
vm-script.txt             the game's bytecode scripts, decoded (generated from mugsy.skool by tools/vmscript.py)
images/                   pictures used by the HTML (all nine game pictures, the shootout, the 'terrific' bug)
screenshots/              simulator screenshots (game flow, hit man shootout, the "terrific" bug)
analysis/                 strategy optimisation results (best parameters per game length, sensitivity tables)
tools/                    Python tools used to build and analyse it:
  pyvm.py        exact reimplementation of the game's VM (validated against the Z80 code)
  policy.py      strategy representation, handout calculator, SQRT freeze values
  optimise.py    parameterised strategy and random search
  refine.py      coordinate refinement with common random numbers
  sensitivity.py / longrun.py / terms.py / causes.py   analyses on the economics page
  sim.py, probe.py, capture.py, validate*.py, terrific.py   Z80 simulation harnesses (SkoolKit CSimulator)
  shoot.py       runs the shootout routine (42112) standalone, with scripted keys
  pics.py        renders the game's nine pictures by running its own picture routines
  overflow.py    checks the client-buying overflow on the real Z80 code; exploit_eval.py / exploit_refine.py score it in the Python VM
  numentry.py    types text into the number-entry routine and shows how the game reads it
  anim.py        records the bar-room and getaway-car animations as GIFs
  exploit_rich.py  tests strategies built around the buy-clients overflow (repeat each year, spend the cash on ammo)
  shootgif.py    records the restaurant shootout as an animated GIF (scripted keys)
  notes*.py      the hand-written instruction comments (merged by notes.py); audit.py measures coverage
  package.sh     rebuilds the skool file, HTML, asm and ctl, checks the rebuild is byte-identical, makes the zip
  mugsylib.py    text decoder and VM disassembler; build.py + notes.py + data_notes.py generate mugsy.skool
  linkify.py     turns addresses in descriptions and comments into links (used by build.py)
  vmscript.py    writes vm-script.txt
  hobbit_*.py    the comparisons on the Hobbit page; they need a memory image of The Hobbit (not included)

The skool file rebuilds byte-for-byte to the original 40,960 bytes of code and data (24576-65535). Every code
instruction has a comment; about 95% of them are hand-written and the rest are short generated ones (mostly PUSH/POP,
increments and simple jumps).

Running the tools: they expect the project at /home/claude/mugsy (edit ROOT or the paths at the top of a script to move it) and a
memory image of the loaded game in work/mem.bin (the tape's code block at 16384 onwards, 48K, plus work/mugsy_tzx.z80 for
probe.py). mugsy.skool can be built to HTML without any of that: skool2html.py mugsy.skool (SkoolKit 10).

External assembler check: mugsy.asm assembles with sjasmplus 1.24.1 (sjasmplus --raw=out.bin mugsy.asm) to the same 40,960 bytes as the original code (24576-65535).
