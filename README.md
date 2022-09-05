# MI - Sistemas Digitais
## Meta 1 - Timer e pisca led

### Arquivos

- *iomem.s* - Executa a mudança de estado do pino do LED para ALTO (HIGH)
- *iomem_clear.s* - Executa a mudança de estado do pino do LED para BAIXO (LOW)
- *memmap.s* - Pisca o LED _x_ vezes usando o timer interno para contar o tempo entre cada mudança de estado do LED

### Build

O makefile contem 4 alvos principais: `ioset`, `ioclr`, `memmap` e `all`.

```console
make ioset
# liga o LED
sudo ./ioset
```

```console
make ioclr
# desliga o LED
sudo ./ioclr
```

```console
make memmap
# pisca o LED 3 vezes
sudo ./memmap
```

ou para todos:

```console
make

# liga o LED
sudo ./ioset

# desliga o LED
sudo ./ioclr

# pisca o LED 3 vezes
sudo ./memmap
```

### Compilação Manual

```console
# montagem
as -o iomem.o iomem.s
as -o setReg.o setReg.s

# link com gcc (necessário pelas funções de sistema)
gcc -o ioset iomem.o setReg.o
```

```console
# montagem
as -o iomem_clear.o iomem_clear.s
as -o setReg.o setReg.s

# link com gcc (necessário pelas funções de sistema)
gcc -o ioclr iomem_clear.o setReg.o
```