# Projeto ACUtA

**Analisador e Conversor UTF-8 para ASCII em Assembly x86-64**

[![Language](https://img.shields.io/badge/Language-Assembly%20x86--64-blue)](https://www.nasm.us/)
[![Platform](https://img.shields.io/badge/Platform-Linux-orange)](https://www.linux.org/)
[![License](https://img.shields.io/badge/License-Academic-green)](LICENSE)

## Índice

- [Sobre o Projeto](#sobre-o-projeto)
- [Funcionalidades](#funcionalidades)
- [Pré-requisitos](#pré-requisitos)
- [Instalação e Compilação](#instalação-e-compilação)
- [Como Usar](#como-usar)
- [Exemplos](#exemplos)
- [Estrutura do Código](#estrutura-do-código)
- [Detalhes Técnicos](#detalhes-técnicos)
- [Limitações](#limitações)
- [Troubleshooting](#troubleshooting)

---

## Sobre o Projeto

O **ACUtA** (Analisador e Conversor UTF-8 para ASCII) é um programa desenvolvido em **Assembly x86-64** para Linux que processa ficheiros de texto codificados em UTF-8, realizando três operações principais:

1. **Análise e contagem** de diferentes tipos de codificação de caracteres
2. **Filtragem** de caracteres não-ASCII
3. **Conversão** de caracteres portugueses acentuados para ASCII puro

Este projeto foi desenvolvido como parte da disciplina de **Arquiteturas de Sistemas Computacionais** (ASC-LEI/FCUL – 2025/26).

---

## Funcionalidades

### Fase 1: Análise e Contagem
Analisa o ficheiro de entrada e conta:
- Total de bytes do ficheiro
- Número de caracteres ASCII (1 byte)
- Número de caracteres UTF-8 de 2 bytes
- Número de caracteres UTF-8 de 3 bytes
- Número de caracteres UTF-8 de 4 bytes

### Fase 2: Filtragem ASCII
Cria um ficheiro de saída contendo **apenas** os caracteres ASCII do ficheiro original, mantendo a ordem.

### Fase 3: Conversão de Caracteres Portugueses
Converte caracteres portugueses acentuados para os seus equivalentes ASCII:

| Acentuados | → | ASCII |
|-----------|---|-------|
| à, á, â, ã, À, Á, Â, Ã | → | a, A |
| ç, Ç | → | c, C |
| é, ê, É, Ê | → | e, E |
| í, Í | → | i, I |
| ó, ô, õ, ö, Ó, Ô, Õ, Ö | → | o, O |
| ú, ü, Ú, Ü | → | u, U |

---

## Pré-requisitos

### Software Necessário

- **Sistema Operativo**: Linux (Ubuntu, Fedora, Debian, etc.)
- **Assembler**: NASM (Netwide Assembler) 2.14+
- **Linker**: GNU ld
- **Biblioteca**: `Biblioteca.o` (fornecida pelo professor)

### Instalação das Ferramentas

#### Ubuntu/Debian:
```bash
sudo apt update
sudo apt install nasm binutils
```

#### Fedora:
```bash
sudo dnf install nasm binutils
```

#### Arch Linux:
```bash
sudo pacman -S nasm binutils
```

---

## Instalação e Compilação

### 1. Clone o Repositório
```bash
git clone https://github.com/seu-usuario/acuta-projeto.git
cd acuta-projeto
```

### 2. Estrutura de Ficheiros
Certifique-se de que tem a seguinte estrutura:
```
acuta-projeto/
├── fc58838.asm         # Código-fonte do programa
├── Biblioteca.o        # Biblioteca fornecida (funções auxiliares)
├── README.md           # Este ficheiro
└── exemplos/           # Ficheiros de teste (opcional)
    ├── teste.txt
    └── lusiadas1.txt
```

### 3. Compilar o Programa

#### Passo 1: Assemblar o código
```bash
nasm -f elf64 -o fc58838.o fc58838.asm
```

#### Passo 2: Linkar com a biblioteca
```bash
ld -o fc58838 fc58838.o Biblioteca.o
```

#### Ou use um Makefile (opcional):
```makefile
# Makefile
PROG = fc58838
ASM = nasm
LD = ld

all: $(PROG)

$(PROG): $(PROG).o Biblioteca.o
	$(LD) -o $(PROG) $(PROG).o Biblioteca.o

$(PROG).o: $(PROG).asm
	$(ASM) -f elf64 -o $(PROG).o $(PROG).asm

clean:
	rm -f $(PROG) $(PROG).o

.PHONY: all clean
```

Depois compile simplesmente com:
```bash
make
```

---

## Como Usar

### Sintaxe
```bash
./fc58838 <ficheiro_entrada> <ficheiro_contagens> <ficheiro_saida>
```

### Parâmetros
1. **ficheiro_entrada**: Ficheiro de texto codificado em UTF-8 (máximo 2000 bytes)
2. **ficheiro_contagens**: Ficheiro de saída com as estatísticas (5 linhas)
3. **ficheiro_saida**: Ficheiro de saída com o texto convertido em ASCII

### Formato do Ficheiro de Contagens
O ficheiro de contagens terá **5 linhas**, cada uma com **3 dígitos + newline**:
```
XXX    ← Total de bytes
XXX    ← Caracteres ASCII
XXX    ← Caracteres UTF-8 de 2 bytes
XXX    ← Caracteres UTF-8 de 3 bytes
XXX    ← Caracteres UTF-8 de 4 bytes
```

---

## Exemplos

### Exemplo 1: Texto Simples

**Ficheiro de entrada** (`teste.txt`):
```
Olá João! Ção és único.
```

**Executar:**
```bash
./fc58838 teste.txt contagens.txt saida.txt
```

**Resultado** (`contagens.txt`):
```
030
018
006
000
000
```

**Resultado** (`saida.txt`):
```
Ola Joao! Cao es unico.
```

---

### Exemplo 2: Os Lusíadas

**Ficheiro de entrada** (`lusiadas.txt`):
```
AS armas e os Barões assinalados
Que da Ocidental praia Lusitana
Por mares nunca de antes navegados
Passaram ainda além da Taprobana,
Em perigos e guerras esforçados
```

**Executar:**
```bash
./fc58838 lusiadas.txt stats.txt output.txt
```

**Resultado** (`stats.txt`):
```
202
188
007
000
000
```

**Resultado** (`output.txt`):
```
AS armas e os Baroes assinalados
Que da Ocidental praia Lusitana
Por mares nunca de antes navegados
Passaram ainda alem da Taprobana,
Em perigos e guerras esforcados
```

---

### Exemplo 3: Criar Ficheiro de Teste

```bash
# Criar ficheiro com caracteres especiais
cat > teste_acentos.txt << 'EOF'
João comeu pão com açúcar.
A mãe cantou: "Olá! É verão!"
JOSÉ, ANDRÉ e ÂNGELA foram à praia.
EOF

# Executar o programa
./fc58838 teste_acentos.txt contagens.txt resultado.txt

# Ver resultados
echo "=== CONTAGENS ==="
cat contagens.txt

echo -e "\n=== TEXTO CONVERTIDO ==="
cat resultado.txt
```

**Saída esperada:**
```
=== CONTAGENS ===
117
079
019
000
000

=== TEXTO CONVERTIDO ===
Joao comeu pao com acucar.
A mae cantou: "Ola! E verao!"
JOSE, ANDRE e ANGELA foram a praia.
```

---

## Estrutura do Código

### Organização das Secções

```nasm
section .bss
    input_buf  resb 2000    ; Buffer para ficheiro de entrada
    ascii_buf  resb 2000    ; Buffer para ficheiro de saída
    count_buf  resb 32      ; Buffer para contagens
    
    total_bytes resq 1      ; Total de bytes lidos
    ascii_cnt   resq 1      ; Contador de caracteres ASCII
    utf2_cnt    resq 1      ; Contador UTF-8 de 2 bytes
    utf3_cnt    resq 1      ; Contador UTF-8 de 3 bytes
    utf4_cnt    resq 1      ; Contador UTF-8 de 4 bytes
```

### Fluxo do Programa

```
┌─────────────────────┐
│   Início (_start)   │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ Ler argumentos CLI  │
│ (argv[1,2,3])       │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ Ler ficheiro para   │
│ memória (readFile)  │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│   FASE 1: Contagem  │
│ - ASCII, UTF-2/3/4  │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ Escrever contagens  │
│ (writeTextFile)     │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ FASE 2/3: Conversão │
│ - Copiar ASCII      │
│ - Converter PT → EN │
│ - Remover UTF-3/4   │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ Escrever ficheiro   │
│ ASCII (writeFile)   │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│   Exit (syscall)    │
└─────────────────────┘
```

---

## Detalhes Técnicos

### Identificação de Codificação UTF-8

O programa identifica o tipo de codificação analisando os bits mais significativos do primeiro byte:

| Tipo | Padrão de Bits | Bytes Totais | Exemplo |
|------|---------------|--------------|---------|
| ASCII | `0xxxxxxx` | 1 | `a` = 0x61 |
| UTF-2 | `110xxxxx` | 2 | `ã` = 0xC3 0xA3 |
| UTF-3 | `1110xxxx` | 3 | `€` = 0xE2 0x82 0xAC |
| UTF-4 | `11110xxx` | 4 | `😀` = 0xF0 0x9F 0x98 0x80 |

### Códigos UTF-8 dos Caracteres Portugueses

Todos os caracteres portugueses acentuados são codificados com **2 bytes** iniciando com `0xC3`:

```nasm
; Exemplo: ã = 0xC3 0xA3
; Primeiro byte: 0xC3 (indica UTF-2)
; Segundo byte: 0xA3 (código do caractere)

check_c3:
    cmp al, 0xC3           ; Verifica se é 0xC3
    je check_portuguese    ; Se sim, verifica caractere português
```

**Tabela completa:**
```
Minúsculas:
  à = 0xC3 0xA0  →  a
  á = 0xC3 0xA1  →  a
  â = 0xC3 0xA2  →  a
  ã = 0xC3 0xA3  →  a
  ç = 0xC3 0xA7  →  c
  é = 0xC3 0xA9  →  e
  ê = 0xC3 0xAA  →  e
  í = 0xC3 0xAD  →  i
  ó = 0xC3 0xB3  →  o
  ô = 0xC3 0xB4  →  o
  õ = 0xC3 0xB5  →  o
  ú = 0xC3 0xBA  →  u
  ü = 0xC3 0xBC  →  u

Maiúsculas:
  À = 0xC3 0x80  →  A
  Á = 0xC3 0x81  →  A
  Â = 0xC3 0x82  →  A
  Ã = 0xC3 0x83  →  A
  Ç = 0xC3 0x87  →  C
  É = 0xC3 0x89  →  E
  Ê = 0xC3 0x8A  →  E
  Í = 0xC3 0x8D  →  I
  Ó = 0xC3 0x93  →  O
  Ô = 0xC3 0x94  →  O
  Õ = 0xC3 0x95  →  O
  Ú = 0xC3 0x9A  →  U
  Ü = 0xC3 0x9C  →  U
```

### Funções da Biblioteca

```nasm
; Ler ficheiro para memória
readTextFile:
    ; RDI = nome do ficheiro (string terminada em 0)
    ; RSI = buffer de destino
    ; Retorna: RAX = número de bytes lidos

; Escrever buffer para ficheiro
writeTextFile:
    ; RDI = nome do ficheiro
    ; RSI = buffer de origem
    ; RDX = número de bytes a escrever

; Converter número para ASCII (3 dígitos + newline)
utoa3:
    ; RDI = número a converter
    ; RSI = buffer de destino (4 bytes)
    ; Retorna: RAX = RSI
```

---

## Limitações

1. **Tamanho máximo do ficheiro**: 2000 bytes (pode ser aumentado modificando `resb 2000`)
2. **Apenas caracteres portugueses**: Outros caracteres acentuados não são convertidos
3. **UTF-3 e UTF-4**: São removidos (não convertidos)
4. **Codificação de entrada**: Deve ser UTF-8 válido
5. **Plataforma**: Apenas Linux x86-64

---

## Troubleshooting

### Erro: "Segmentation fault"

**Possíveis causas:**
1. Ficheiro de entrada maior que 2000 bytes
2. Biblioteca.o não está no diretório correto
3. Argumentos da linha de comando incorretos

**Soluções:**
```bash
# Verificar tamanho do ficheiro
wc -c ficheiro.txt

# Verificar se Biblioteca.o existe
ls -la Biblioteca.o

# Usar GDB para debug
gdb ./fc58838
(gdb) run entrada.txt contagens.txt saida.txt
(gdb) bt
```

---

### Erro: "Command not found"

**Causa:** NASM não está instalado

**Solução:**
```bash
# Ubuntu/Debian
sudo apt install nasm

# Fedora
sudo dnf install nasm
```

---

### Contagens aparecem como "000"

**Causa:** Ficheiro de entrada vazio ou não foi lido corretamente

**Solução:**
```bash
# Verificar se o ficheiro existe e tem conteúdo
cat ficheiro_entrada.txt

# Verificar permissões
ls -la ficheiro_entrada.txt
chmod 644 ficheiro_entrada.txt
```

---

### Caracteres não são convertidos

**Causa:** Caracteres podem não estar na lista suportada

**Solução:** Verifique a tabela de conversão. Apenas caracteres portugueses específicos são suportados.

---

## Notas de Desenvolvimento

### Como Modificar o Tamanho Máximo do Ficheiro

Edite a linha no código:
```nasm
section .bss
    input_buf  resb 5000    ; Era 2000, agora 5000 bytes
    ascii_buf  resb 5000
```

### Como Adicionar Novos Caracteres

Para adicionar suporte a novos caracteres acentuados:

1. Consulte a tabela UTF-8: https://www.utf8-chartable.de/
2. Adicione a verificação no código:

```nasm
check_c3:
    movzx rbx, byte [input_buf+r8+1]
    
    ; Exemplo: adicionar suporte para ë (0xC3 0xAB)
    cmp bl, 0xAB
    je put_e
```

---

## Testes

### Script de Teste Automático

```bash
#!/bin/bash
# test.sh

echo "=== Teste 1: ASCII puro ==="
echo "Hello World" > test1.txt
./fc58838 test1.txt out1_count.txt out1_ascii.txt
cat out1_count.txt

echo -e "\n=== Teste 2: Caracteres portugueses ==="
echo "João comeu pão" > test2.txt
./fc58838 test2.txt out2_count.txt out2_ascii.txt
cat out2_count.txt
cat out2_ascii.txt

echo -e "\n=== Teste 3: Misto ==="
echo "Olá! 123 José €" > test3.txt
./fc58838 test3.txt out3_count.txt out3_ascii.txt
cat out3_count.txt
cat out3_ascii.txt

# Limpar
rm -f test*.txt out*.txt
```

Execute:
```bash
chmod +x test.sh
./test.sh
```
---

## 🔗 Recursos Úteis

- [NASM Documentation](https://www.nasm.us/doc/)
- [UTF-8 Character Table](https://www.utf8-chartable.de/)
- [x86-64 Assembly Guide](https://cs.brown.edu/courses/cs033/docs/guides/x64_cheatsheet.pdf)
- [Linux System Calls](https://man7.org/linux/man-pages/man2/syscalls.2.html)

---

## Suporte

Para questões ou problemas:
1. Consulte a secção [Troubleshooting](#troubleshooting)
2. Verifique os [Exemplos](#exemplos)
3. Use GDB para debug detalhado

---

**Última atualização:** Dezembro 2025  
**Versão:** 1.0.0
