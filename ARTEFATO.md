
# Sistema de Registro IoT com pfSense

## Objetivo
Este repositório tem como objetivo armazenar todo o código produzido, exemplificar o funcionamento prático do sistema de orquestração multi-IDS para ambientes IoT, e documentar os procedimentos de instalação, execução e reivindicações do artigo.

## Resumo do Artigo
Ambientes IoT ampliam a superfície de ataque e dificultam a resposta a incidentes. O IoT-Edu orquestra múltiplos IDSs (Suricata, Snort, Zeek) em um pipeline unificado com correlação de eventos e bloqueio automatizado. Em cinco tipos de ataque (75 execuções), o sistema alcança contenção média de 5,56 s, com a latência dominada pela fase de detecção. Os resultados expõem um compromisso entre a velocidade dos métodos baseados em assinaturas e o contexto dos baseados em comportamento, demonstrando que a orquestração multi-IDS melhora a resposta automatizada em ambientes IoT dinâmicos.

---

# Estrutura do README.md

Este README.md está organizado nas seguintes seções:

1. **Título, Objetivo e Resumo:** Título do projeto, objetivo do artefato e resumo do artigo.
2. **Estrutura do README.md:** A presente estrutura.
3. **Selos considerados:** Lista dos Selos a serem considerados no processo de avaliação.
4. **Informações básicas:** Descrição dos componentes e requisitos mínimos para a execução do experimento.
5. **Dependências:** Informação sobre as dependências necessárias.
6. **Preocupações com segurança:** Lista das considerações e preocupações com a segurança.
7. **Instalação:** Instruções para instalação e configuração do sistema.
8. **Teste mínimo:** Instruções para a execução de um teste mínimo.
9. **Experimentos:** Informações de replicação das reivindicações.
10. **Licença:** Informações sobre a licença do projeto.

---

## Estrutura do Repositório


```
.
├── backend/            # Código-fonte do backend, scripts de banco de dados, autenticação e deploy
├── frontend/           # Código-fonte do frontend (Next.js)
├── diagramas/          # Diagramas de arquitetura e documentação visual
├── ids-log-monitor/    # Scripts e ferramentas para monitoramento de logs
├── resultados/         # Resultados de experimentos e análises
├── Dockerfile          # Configuração Docker
└── ...                 # Scripts de deploy e configuração na raiz
```

---

## Selos Considerados

Os selos considerados são:
- Artefatos Disponíveis (SeloD)
- Artefatos Funcionais (SeloF)

---

---

## Informações Básicas


### Requisitos de Software

| Componente | Versão Mínima |
|---|---|
| Python | 3.9+ (testado com 3.12) |
| MySQL / MariaDB | 8.0+ |
| pfSense | 2.8.1 (veja [Passo 3](#3-configuração-do-pfsense)) |
| Node.js | 18+ |
| npm / pnpm | qualquer versão recente |

### Requisitos de Hardware (referência dos autores)

| Componente | Especificação |
|---|---|
| CPU | AMD Ryzen 5 5600X (6 núcleos, 3,7 GHz) |
| Memória RAM | 32 GB DDR4 |
| GPU | NVIDIA GeForce RTX 3070 Ti 8 GB |
| SO | Ubuntu / Kubuntu 24.04 LTS (bare-metal) |

> **Nota:** O sistema pode ser executado em hardware mais modesto, mas os tempos de resposta reportados no artigo foram obtidos nesta configuração.

---

---

## Dependências


### Dependências do Sistema Operacional

Antes de instalar os pacotes Python, instale as bibliotecas de sistema necessárias. No Ubuntu/Debian:

```bash
sudo apt update
sudo apt install -y \
    python3 python3-pip python3-venv python3-dev \
    libxml2-dev libxmlsec1-dev libxmlsec1-openssl \
    default-libmysqlclient-dev build-essential pkg-config
```

> **Atenção (Ubuntu 22.04+):** A instalação de pacotes Python com `pip` fora de um ambiente virtual não é mais permitida diretamente. Sempre use um ambiente virtual (ver Instalação).

### Dependências Python

Todas as dependências estão listadas em `backend/requirements.txt`. Além das entradas já presentes no arquivo, certifique-se de que os seguintes pacotes estejam incluídos (ou instale-os manualmente caso encontre erros):

```
pymysql
itsdangerous
Authlib
```

> Se ao executar qualquer script você encontrar `ModuleNotFoundError: No module named 'X'`, execute `pip install X` com o ambiente virtual ativado.

### Dependências do Frontend

```bash
cd frontend
npm install   # ou: pnpm install
```

### Acessos a Recursos de Terceiros

- **Google OAuth:** requer `client_id` e `client_secret` configurados no Google Cloud Console.
- **pfSense REST API:** requer chave de API gerada na interface web do pfSense (ver [Passo 3](#3-configuração-do-pfsense)).

---

## Preocupações com Segurança


- Não exponha o pfSense diretamente à internet durante os testes. Utilize uma rede isolada ou laboratório virtual.
- O arquivo `backend/.env` contém credenciais sensíveis (banco de dados, OAuth, chave de API do pfSense). Nunca versione esse arquivo.
- A chave de API do pfSense gerada durante o setup deve ser tratada como senha. Regenere-a após a avaliação.
- Os scripts de setup criam um usuário SUPERUSER cujas credenciais são definidas nas variáveis de ambiente — altere-as antes de qualquer uso em produção.

---

---

## Instalação


### 0. Pré-requisito: clonar o repositório

```bash
git clone https://github.com/GT-IoTEdu/API_SBRC26_SF.git
cd API_SBRC26_SF
```

### 1. Criar e ativar o ambiente virtual Python

```bash
python3 -m venv venv
source venv/bin/activate
```

> O prompt do terminal deverá exibir `(venv)` indicando que o ambiente está ativo. Todos os comandos `pip` e `python` a seguir devem ser executados com o ambiente ativo.

### 2. Instalar as dependências do sistema

```bash
sudo apt update
sudo apt install -y \
    python3-dev libxml2-dev libxmlsec1-dev libxmlsec1-openssl \
    default-libmysqlclient-dev build-essential pkg-config
```

### 3. Instalar as dependências Python

```bash
pip install -r backend/requirements.txt
```

Se algum módulo estiver faltando, instale manualmente:

```bash
pip install pymysql itsdangerous Authlib
```

### 4. Configurar as variáveis de ambiente

Copie o arquivo de exemplo e preencha com suas credenciais:

```bash
cp backend/env_example.txt backend/.env
```

Edite `backend/.env` e preencha ao menos:

```
# ===============================
# Configurações do banco de dados MySQL
# ===============================

# Nome do usuário do banco de dados
MYSQL_USER=

# Senha do usuário do banco de dados
MYSQL_PASSWORD=

# Endereço do servidor MySQL (localhost para máquina local)
MYSQL_HOST=localhost

# Nome do banco de dados a ser utilizado
MYSQL_DB=


# ===============================
# Configurações de email (opcional)
# ===============================

# Servidor SMTP para envio de emails (ex: Gmail)
EMAIL_HOST=smtp.gmail.com

# Porta do servidor SMTP (587 geralmente usa TLS)
EMAIL_PORT=587

# Define se a conexão usará TLS (True ou False)
EMAIL_USE_TLS=True

# Email remetente utilizado para envio
EMAIL_HOST_USER=seu_email@gmail.com

# Senha do email ou senha de app (recomendado para Gmail)
EMAIL_HOST_PASSWORD=sua_senha_email_aqui


# ===============================
# Configurações de autenticação Google (OAuth)
# ===============================

# ID do cliente fornecido pelo Google Cloud
GOOGLE_CLIENT_ID=

# Chave secreta do cliente Google
GOOGLE_CLIENT_SECRET=


# ===============================
# Segurança da aplicação
# ===============================

# Chave secreta usada para criptografia e sessões (gerar uma segura)
SECRET_KEY=

# Define se a sessão deve ser estritamente validada (true/false)
AUTH_STRICT_SESSION=true


# ===============================
# Configuração de faixa de IP
# ===============================

# IP inicial da faixa permitida
IP_RANGE_START=192.168.59.1

# IP final da faixa permitida
IP_RANGE_END=192.168.59.99

# Lista de IPs excluídos da faixa (separados por vírgula)
IP_RANGE_EXCLUDED=192.168.59.1,192.168.59.2


# ===============================
# Controle de acesso
# ===============================

# Email do usuário com privilégios de superusuário (login via Google)
SUPERUSER_ACCESS=seu_email@gmail.com
AUTH_STRICT_SESSION=false
IDS_SSE_TLS_VERIFY=false
```

---

## Configuração

### 5. Configurar o banco de dados MySQL

Acesse o MySQL como root e crie o banco e o usuário:

```bash
sudo mysql -u root
```

Dentro do shell MySQL, execute:

```sql
CREATE DATABASE IF NOT EXISTS iot_edu CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS 'IoT_EDU'@'localhost' IDENTIFIED BY '<sua_senha>';
GRANT ALL PRIVILEGES ON iot_edu.* TO 'IoT_EDU'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

Em seguida, crie as tabelas executando o script de setup (com o ambiente virtual ativo, a partir da raiz do repositório):

```bash
cd backend
python -m db.setup_database
cd ..
```

Para verificar se as tabelas foram criadas corretamente:

```bash
sudo mysql -u IoT_EDU -p iot_edu
```

Dentro do shell MySQL:

```sql
USE iot_edu;
SHOW TABLES;
```

Você deve ver a lista de tabelas criadas pelo script.

### 6. Configurar o pfSense e gerar a chave de API

> **Versão suportada:** pfSense **2.8.1**. O pacote API REST (pfSense-pkg-RESTAPI) pode não estar disponível no Package Manager de todas as versões — instale pela linha de comando se necessário.

#### 6a. Instalar o pacote REST API

No shell do pfSense (acesse via SSH ou console):

```bash
pkg-static add https://github.com/pfrest/pfSense-pkg-RESTAPI/releases/latest/download/pfSense-2.8.1-pkg-RESTAPI.pkg
```

#### 6b. Gerar a chave de API

1. Acesse a interface web do pfSense em `https://<ip-do-pfsense>`.
2. Vá em **System → REST API → Keys**.
3. Clique em **Add** e selecione o tipo **SHA256** com tamanho **32** (utilize 16 ou 32 — 36 não é um tamanho válido).
4. Copie a chave gerada e insira no campo `PFSENSE_API_KEY` do arquivo `backend/.env`.

---

## Teste Mínimo

### 7. Iniciar o servidor backend

Com o ambiente virtual ativo e a partir do diretório `backend/`:

```bash
cd backend
python start_server.py
```

O servidor deve iniciar em `http://127.0.0.1:8000`. Você verá no terminal mensagens como:

```
✔ Configurações OK! Iniciando servidor...
INFO: Uvicorn running on http://127.0.0.1:8000
```

### 8. Instalar dependências e iniciar o frontend

Em outro terminal:

```bash
cd frontend
npm install
npm run dev
```

### 9. Primeiro acesso e configuração inicial

1. Acesse a interface web (endereço exibido pelo frontend, geralmente `http://localhost:3000`).
2. Realize login com as credenciais do `SUPERUSER` definidas no `.env`.
3. Crie uma **instituição** e um usuário **ADMIN** pela interface web.
4. Execute o script de configuração de aliases e regras no pfSense:

```bash
cd backend
python scripts/setup_initial_aliases_and_rules.py
```

5. Verifique se os aliases e regras foram criados tanto no banco de dados quanto no pfSense.

> **Nota de ordenação:** o passo de configuração inicial dos aliases (equivalente ao antigo "Passo 4" da documentação original) deve ser executado **após** o servidor estar em execução e o pfSense configurado. Por isso foi posicionado aqui.

---

## Experimentos


### **Reivindicação #1 — Tempo médio de contenção de 5,56 s**

Para garantir a reprodutibilidade dos resultados apresentados, descreve-se a seguir o procedimento necessário para execução dos experimentos, incluindo a configuração do ambiente e a realização dos 75 testes (5 tipos de ataque × 15 execuções).

Inicialmente, é necessário configurar um ambiente virtualizado contendo os componentes da arquitetura IoT-Edu, incluindo o firewall pfSense, os sistemas de detecção de intrusão (IDS) e o módulo de coleta de eventos.

**Passo 1 — Configuração do firewall**
Instalar e configurar uma máquina virtual com o pfSense, responsável pela aplicação das regras de bloqueio dinâmico.

**Passo 2 — Configuração dos IDS**
Instalar e configurar os IDS Suricata, Snort e Zeek em uma máquina virtual dedicada ao monitoramento. Os sistemas devem estar operando em modo de captura e configurados para gerar logs nos seguintes diretórios padrão:

* Suricata: `/var/log/suricata/fast.log`
* Snort: `/var/log/snort/alert`
* Zeek: `/home/ubuntu/zeek-logs/notice.log`

**Passo 3 — Execução do servidor de eventos (SSE)**
O script responsável pela coleta e transmissão dos eventos (`sse_server.py`) deve ser executado no mesmo ambiente dos IDS.

1. Ajustar os caminhos dos arquivos de log no código:

   ```
   LOG_FILE_SURICATA = "/var/log/suricata/fast.log"
   LOG_FILE_SNORT = "/var/log/snort/alert"
   LOG_FILE_ZEEK = "/home/ubuntu/zeek-logs/notice.log"
   ```

2. Ativar o ambiente virtual:

   ```
   source venv/bin/activate
   ```

3. Iniciar o servidor SSE:

   ```
   uvicorn sse_server:app --host 0.0.0.0 --port 8001
   ```

**Passo 4 — Execução dos ataques e coleta de métricas**
Os cenários de ataque utilizados nos experimentos estão disponíveis no repositório:

* eng-ids ataques docker

A documentação detalhada para instalação e execução encontra-se em:
[https://github.com/MatheusCiocca/eng-ids/blob/main/ataques_docker/DOCKER_USAGE.md](https://github.com/MatheusCiocca/eng-ids/blob/main/ataques_docker/DOCKER_USAGE.md)

Os ataques devem ser executados a partir de uma máquina virtual dedicada ao papel de atacante, contemplando os seguintes cenários:

* HTTP Flood
* ICMP Flood
* DNS Tunneling
* SSH Brute Force
* SQL Injection


---

Cada ataque deve ser executado **5 vezes para cada tipo de ataque e para cada IDS**, totalizando 75 execuções.

Durante a execução de cada ataque, deve-se iniciar simultaneamente o script de monitoramento responsável pela coleta dos tempos de contenção:

```
ids-log-monitor/monitor.py
```

Esse script registra os *timestamps* associados às etapas de início do ataque e de aplicação do bloqueio — momento em que o atacante perde o acesso à rede —, permitindo o cálculo da métrica de tempo de contenção (Início–Falha).

---


## Licença

Copyright (c) 2025 RNP – National Research and Education Network (Brazil)

This code was developed is licensed under the terms of the BSD License. It may be freely used, modified, and distributed, including for commercial purposes, provided that this copyright notice is retained. This software is provided "as is", without any warranty, express or implied, including, but not limited to, warranties of merchantability or fitness for a particular purpose. RNP and the authors shall not be held liable for any damages or losses arising from the use of this software.