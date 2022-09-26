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

## Softwares Utilizados

## Arquitetura do computador
### Raspberry Pi Zero W
- CPU Broadcom BCM2835 SOC
- ARM1176JZF-S core type
- Single-core
- Clock Speed 1 GHz
- RAM 512 MB
- GPIO 40-Pins

## Tipos de instrução utilizadas
- MOV - Move: Move um endereço/valor para um registrador
- ADD - Addition: Faz uma adição entre dois operandos e coloca o resultado em um registrador de destino 
- SUB - Subtraction: Faz uma subtração entre dois operandos e coloca o resultado em um registrador de destino
- MUL - Multiplication: Faz uma multiplicação entre dois operandos e coloca o resultado em um registrador de destino
- LDR - Load: Carrega dados da memória para um registrador
- STR - Store: Armazena dados de um registrador na memória
- BL  - Branch and Link: O programa faz um desvio nas instruções e guarda o valor do pc (program counter) no lr (link register)
- BX  - Branch Exchange: O programa faz um desvio para o endereço de memória de um registrador alvo.
- ORR - Faz uma operação lógica do tipo OR entre dois valores.
- BIC - Bit Clear: Faz uma operação lógica do tipo AND entre dois valores, o primeiro normal e o segundo valor negado (NOT).
- AND - Faz uma operação lógica do tipo AND entre dois valores.
- LSL - Logical Shift Left: "Empurra" os bits pra esquerda com 0's. Equivale a multiplicar por 2^n, com *n* sendo o número de deslocamentos
- LSR - Logical Shift Right: "Empurra" os bits pra direita com 0's. Equivale a dividir por 2^n, com *n* sendo o número de deslocamentos

## Descrição de instalação, configuração de ambiente e execução;
