# MI - Sistemas Digitais (TEC499)

## Proposta
Desenvolver um aplicativo de temporização (timer) na *Raspberry Pi Zero W*, que apresente a contagem num
display LCD. O tempo inicial deverá ser configurado diretamente no código. Além disso,
deverão ser usados 2 botões (push buttons) de controle: um para iniciar/parar a contagem e outro para reiniciar
a partir do tempo definido.

Com o objetivo de desenvolver uma biblioteca para uso futuro em conjunto com um
programa em linguagem C, a função para enviar mensagem para o display deve estar
separada como uma biblioteca (.o), e permitir no mínimo as seguinte operações:
- Limpar display.
- Escrever caractere.
- Posicionar cursor (linha e coluna).

## Produto desenvolvido
- O temporizador faz a contagem em segundos no display num intervalo de 00 a 99. Após o último dígito o temporizador reinicia voltando para o 00 e retomando a contagem.
- O botão de pause/resume funciona, porém precisa ser apertado por ao menos 1 segundo antes de ser solto para o funcionamento adequado.
- O botão de reinicio funciona, voltando o contador para o 0.

## Softwares Utilizados
- Visual Code Studio: Editor de código-fonte utilizado como ambiente de desenvolvimento, no qual foi usado juntamente com a extensão *Arm Assembly* v1.7.4 do autor *dan-c-underwood*, disponibilizada pelo próprio marketplace do software.

## Recursos Utilizados
<div id="image11" style="display: inline_block" align="center">
		<img src="/protoboard.jpg"/><br>
		<p>
		Kit de desenvolvimento
		</p>
	</div>

- Raspberry Pi Zero W
- Display LCD Hitachi HD44780U
- GPIO Extension Board
- 2 Push Buttons

### Raspberry Pi Zero W

<div id="image11" style="display: inline_block" align="center">
		<img src="/raspberry.jpg"/><br>
		<p>
		Raspberry Pi Zero W
		</p>
	</div>

- [Documentação](https://www.raspberrypi.com/documentation/)
- [CPU Broadcom BCM2835 SOC](https://www.raspberrypi.org/app/uploads/2012/02/BCM2835-ARM-Peripherals.pdf)
- ARM1176JZF-S core type
- Single-core
- Clock Speed 1 GHz
- RAM 512 MB
- GPIO 40-Pins

#### Pinos Utilizados

- GPIO 05 - Input -> Push Button 1
- GPIO 19 - Input -> Push Button 2

- GPIO 12 - Output -> D4 (LCD)
- GPIO 16 - Output -> D5 (LCD)
- GPIO 20 - Output -> D6 (LCD)
- GPIO 21 - Output -> D7 (LCD)

- GPIO 01 - Output -> E (LCD)
- GPIO 25 - Output -> RS (LCD)

### Display LCD 16x2 Hitachi 44780

<div id="image11" style="display: inline_block" align="center">
		<img src="/display.jpg"/><br>
		<p>
		Display
		</p>
	</div>
  
- [Documentação](https://www.sparkfun.com/datasheets/LCD/HD44780.pdf)

#### Pinos Utilizados

- D4, D5, D6, D7
- E (Enable)
- RS


## Tipos de instrução utilizadas
### Instruções aritméticas
- ADD - Addition: Faz uma adição entre dois operandos e coloca o resultado em um registrador de destino 
- SUB - Subtraction: Faz uma subtração entre dois operandos e coloca o resultado em um registrador de destino
- MUL - Multiplication: Faz uma multiplicação entre dois operandos e coloca o resultado em um registrador de destino
### Instruções de transferência de dados
- MOV - Move: Move um endereço/valor para um registrador
- LDR - Load: Carrega dados da memória para um registrador
- STR - Store: Armazena dados de um registrador na memória
### Instruções lógicas
- AND - Faz uma operação lógica do tipo AND entre dois valores.
- ORR - Faz uma operação lógica do tipo OR entre dois valores.
- BIC - Bit Clear: Faz uma operação lógica do tipo AND entre dois valores, o primeiro normal e o segundo valor negado (NOT).
- LSL - Logical Shift Left: "Empurra" os bits pra esquerda com 0's. Equivale a multiplicar por 2^n, com *n* sendo o número de deslocamentos
- LSR - Logical Shift Right: "Empurra" os bits pra direita com 0's. Equivale a dividir por 2^n, com *n* sendo o número de deslocamentos
### Instruções de desvio
- BL  - Branch and Link: O programa faz um desvio nas instruções e guarda o valor do pc (program counter) no lr (link register)
- BX  - Branch Exchange: O programa faz um desvio para o endereço de memória de um registrador alvo.

## Instalação, configuração de ambiente e execução
### Arquivos

- *funcs.s* - Declaração de macros e constantes básicos para o mapeamento de memória e configuração de registradores de GPIO.

- *lcd_instructions.s* - Declaração de comandos e constantes para comunicação com o LCD (HD44780).

- *lcdtest.s* - Programa de teste de comunicação com o LCD, neste teste, ele lê o estado do pino GPIO5, imprime um contador de segundos, zerando ao segurar-se o botão do pino GPIO5.

- *inputest.s* - Programa de teste de entrada, lê o registrador de nível dos pinos e filtra para o pino específico a ser testado.

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
