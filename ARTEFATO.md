
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
DATABASE_URL=mysql+pymysql://IoT_EDU:<senha>@localhost/iot_edu
PFSENSE_API_KEY=<chave gerada no Passo 6>
GOOGLE_CLIENT_ID=<seu client_id>
GOOGLE_CLIENT_SECRET=<seu client_secret>
SUPERUSER_EMAIL=<seu email>
SUPERUSER_PASSWORD=<sua senha>
```

---

## Configuração

### 5. Configurar o banco de dados MySQL/MariaDB

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

> TODO: Adicionar passo a passo detalhado para execução e obtenção dos resultados do artigo, detalhando cada reivindicação.

### Reivindicação #1 — Tempo médio de contenção de 5,56 s

TODO: Descrever os comandos e scripts para reproduzir os 75 testes (5 tipos de ataque × 15 execuções) e como coletar os tempos de contenção.

### Reivindicação #2 — Trade-off entre IDSs baseados em assinatura e comportamento

TODO: Descrever como comparar os resultados individuais do Suricata, Snort e Zeek e reproduzir a análise de latência por fase de detecção.

---

## Licença

TODO: Adicionar licença do projeto.