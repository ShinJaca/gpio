# Makefile para biblioteca de interface com LCD 1602

# Opções de compilador e montador
COMPOPTS = -Wall
COMPOUTPUT = lcdtest
ASPIZERO = -mcpu=arm1176jz-s --defsym .pimodel=0
ASPIDOIS = -mcpu=cortex-a7 --defsym .pimodel=2


# all: lcdtest clean


# LCD
# Para RaspberryPi 2
raspdois: lcdtest2 clean
lcdtest2: lcdtest2.o
	gcc $(COMPOPTS) -o $(COMPOUTPUT) $+
lcdtest2.o: lcdtest.s
	as -o $@ $< $(ASPIDOIS)

# Para RaspberryPi Zero
raspzero: lcdtestZ clean
lcdtestZ: lcdtestZ.o
	gcc $(COMPOPTS) -o $(COMPOUTPUT) $+
lcdtestZ.o: lcdtest.s
	as -o $@ $< $(ASPIZERO)



# Input

intest: inputtest clean
inputtest: inputtest.o
	gcc -o $@ $+
inputtest.o: inputtest.s
	as -o $@ $<

clean:
	rm -vf *.o