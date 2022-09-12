all: ioset ioclr memmap clean

# Executáveis

ioset: iomem.o setReg.o
	gcc -o $@ $+
ioclr: iomem_clear.o setReg.o
	gcc -o $@ $+
memmap: memmap.o setReg.o
	gcc -o $@ $+

# Objetos principais

iomem.o: iomem.s
	as -o $@ $<
iomem_clear.o: iomem_clear.s
	as -o $@ $<
memmap.o: memmap.s
	as -o $@ $<

# Bibliotecas

setReg.o: setReg.s
	as -o $@ $<

teste: teste.o
	gcc -o $@ $+
teste.o: teste.s
	as -o $@ $<


lcd: lcdtest clean
lcdtest: lcdtest.o
	gcc -o $@ $+
lcdtest.o: lcdtest.s
	as -o $@ $<

clean:
	rm -vf *.o