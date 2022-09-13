# MI - Sistemas Digitais
## Meta 2 - Caractere em LCD

### Arquivos

- *funcs.s* - declaração de macros e constantes básicos para o mapeamento de memória e configuração de registradores de GPIO

- *lcd_instructions.s* - declaração de comandos e constantes para comunicação com o LCD (HD44780)

- *lcdtest.s* - programa de teste de comunicação com o LCD

### Build

```console
make

# ou
make lcdtest

# para limpeza
make clean
```

### Compilação Manual

```console
# montagem
as -o lcdtest.o lcdtest.s

# link com gcc (necessário pelas funções de sistema)
gcc -o lcdtest lcdtest.o
```