# MI - Sistemas Digitais
## Meta 3 - Leitura de Botão

### Arquivos

- *funcs.s* - declaração de macros e constantes básicos para o mapeamento de memória e configuração de registradores de GPIO

- *lcd_instructions.s* - declaração de comandos e constantes para comunicação com o LCD (HD44780)

- *lcdtest.s* - programa de teste de comunicação com o LCD, neste teste, ele lê o estado do pino GPIO5, imprime um contador de segundos, zerando ao segurar-se o botão do pino GPIO5

- *inputest.s* - programa de teste de entrada, lê o registrador de nível dos pinos e filtra para o pino específico a ser testado

### Build

```console
make

# ou
make lcdtest

# ou
make inputest

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