all: ioset ioclr clean

# Executáveis

ioset: iomem.o setReg.o
	gcc -o $@ $+
ioclr: iomem_clear.o setReg.o
	gcc -o $@ $+

# Objetos principais

iomem.o: iomem.s
	as -o $@ $<
iomem_clear.o: iomem_clear.s
	as -o $@ $<

# Bibliotecas

setReg.o: setReg.s
	as -o $@ $<


clean:
	rm -vf *.o