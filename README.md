<<<<<<< HEAD
# 🐧 Automatizando a Criação e Gerenciamento de Recursos na Azure Usando Apenas o Terminal

## ✍️ Introdução

Este artigo explora como criar, gerenciar e interagir com diversos serviços da Microsoft Azure utilizando **exclusivamente o terminal**, sem nenhuma dependência de interfaces gráficas. Ideal para ambientes headless, pipelines de CI/CD, e usuários que desejam documentar ou automatizar sua infraestrutura em nuvem.

---

## 🔧 Pré-requisitos

- Conta ativa na Azure
- Terminal funcional (Linux/macOS/WSL)
- Azure CLI instalada
  👉 [Guia oficial de instalação](https://learn.microsoft.com/pt-br/cli/azure/install-azure-cli)

---

## 📥 Instalando a Azure CLI

```bash
# Debian/Ubuntu
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# macOS (Homebrew)
brew install azure-cli
```

---

## 🔐 Autenticação sem Interface Gráfica

### 1. Código de Dispositivo (semi-interativo)

```bash
az login --use-device-code
```

- Exibe URL + código para autenticação em outro dispositivo.
- Após validar, o terminal será autenticado.

---

### 2. Service Principal (automatizado/headless)

#### a) Criar credenciais:

```bash
az ad sp create-for-rbac --name "meu-sp" --role Contributor --scopes /subscriptions/<ID_DA_ASSINATURA>
```

#### b) Autenticar:

```bash
az login --service-principal \
  --username APP_ID \
  --password SENHA \
  --tenant TENANT_ID
```

⚠️ **Não exponha essas credenciais publicamente.**

---

## 🧾 Verificando Informações da Conta Após o Login

Após autenticar com `az login`, é importante saber quais subscriptions, tenants e permissões estão associadas à sua conta. Aqui estão os principais comandos:

### 🔍 1. Listar contas e subscriptions disponíveis

```bash
az account list --output table
```

- Lista todas as subscriptions associadas à conta atual.
- Indica qual está como **ativa** no momento.

### 🧑‍💼 2. Ver detalhes da conta atual

```bash
az account show --output json
```

Ou, de forma mais resumida e limpa:

```bash
az account show --query "{Assinatura:name, ID:id, Tenant:tenantId}" --output table
```

### 🔁 3. Trocar de subscription (se houver mais de uma)

```bash
az account set --subscription "Nome-ou-ID-da-subscription"
```

### 🔐 4. Ver permissões e papéis atribuídos

```bash
az role assignment list --output table
```

Ou para um usuário específico:

```bash
az role assignment list --assignee <seu-email-ou-app-id> --output table
```

Esses comandos ajudam a garantir que você tem acesso e permissões corretas antes de criar recursos.

---

## ☁️ Criando Infraestrutura Básica com Azure CLI

### 🧱 1. Grupo de Recursos

```bash
az group create --name MeuGrupo --location eastus
```

---


---

## 🧱 Criando Máquinas Virtuais com Customizações Avançadas
<!-- Detalhamento de parâmetros e exemplos variados para criar VMs customizadas conforme o workload. -->

### 🔢 Parâmetros mais comuns para customização

| Parâmetro               | Descrição                                                         |
|-------------------------|-------------------------------------------------------------------|
| `--image`               | Escolha da imagem (UbuntuLTS, WindowsServer, etc.)               |
| `--size`                | Tamanho da VM (ex: `Standard_B1s`, `Standard_D2s_v3`)            |
| `--admin-username`      | Nome do usuário administrador                                     |
| `--authentication-type` | Tipo de autenticação (`password` ou `ssh`)                       |
| `--generate-ssh-keys`   | Gera chave SSH localmente                                        |
| `--custom-data`         | Script de cloud-init para automação                             |
| `--os-disk-size-gb`     | Tamanho do disco do SO                                           |
| `--data-disk-sizes-gb`  | Lista de tamanhos para discos de dados adicionais               |
| `--public-ip-address`   | Nome ou `""` para não criar IP público                          |
| `--nics`                | Associar interface de rede customizada                          |
| `--vnet-name` / `--subnet` | Usar rede virtual e sub-rede específicas                    |

---

### 🧰 Cenários práticos

#### 1. 🧪 VM leve para testes rápidos (Linux, barata)

```bash
az vm create \
  --resource-group MeuGrupo \
  --name TesteVM \
  --image UbuntuLTS \
  --size Standard_B1s \
  --admin-username devuser \
  --generate-ssh-keys \
  --public-ip-sku Basic
```

---

#### 2. 📦 VM com disco extra e script de inicialização

```bash
az vm create \
  --resource-group MeuGrupo \
  --name VMComDisco \
  --image UbuntuLTS \
  --size Standard_D2s_v3 \
  --admin-username admin \
  --generate-ssh-keys \
  --custom-data cloud-init.txt \
  --data-disk-sizes-gb 20 30
```

---

#### 3. 🔐 VM sem IP público, uso interno (segurança)

```bash
az vm create \
  --resource-group MeuGrupo \
  --name VMInterna \
  --image UbuntuLTS \
  --size Standard_B2s \
  --admin-username internal \
  --generate-ssh-keys \
  --vnet-name vnet-interna \
  --subnet subnet-segura \
  --public-ip-address ""
```

---

#### 4. 🪟 VM com Windows Server + senha

```bash
az vm create \
  --resource-group MeuGrupo \
  --name WindowsVM \
  --image Win2022Datacenter \
  --admin-username winadmin \
  --admin-password "SenhaForte123!" \
  --authentication-type password
```

---

#### 5. 📡 VM em rede personalizada com NIC
---

## 🚀 Presets para Workloads Avançados
<!-- Modelos prontos para diferentes tipos de carga de trabalho como IA, banco de dados, web e renderização. -->

Aqui estão modelos de criação de VMs otimizadas para diferentes tipos de carga de trabalho.

---

### 📊 1. VM para Banco de Dados (alta IOPS + disco premium)

```bash
az vm create \
  --resource-group MeuGrupo \
  --name VMDatabase \
  --image UbuntuLTS \
  --size Standard_E4s_v3 \
  --os-disk-size-gb 128 \
  --storage-sku Premium_LRS \
  --data-disk-sizes-gb 512 512 \
  --admin-username dbadmin \
  --generate-ssh-keys
```

---

### 🧠 2. VM para Machine Learning / IA (GPU)

```bash
az vm create \
  --resource-group MeuGrupo \
  --name VMLearning \
  --image UbuntuLTS \
  --size Standard_NC6 \
  --admin-username mluser \
  --generate-ssh-keys
```

---

### 🕸️ 3. VM para Servidor Web de Alto Tráfego

```bash
az vm create \
  --resource-group MeuGrupo \
  --name WebServerVM \
  --image UbuntuLTS \
  --size Standard_D4s_v3 \
  --admin-username webadmin \
  --generate-ssh-keys \
  --custom-data cloud-init-web.txt \
  --public-ip-sku Standard
```

---

### 📽️ 4. VM para Renderização ou Trabalho Gráfico (GPU Visual)

```bash
az vm create \
  --resource-group MeuGrupo \
  --name VMRender \
  --image Win2019Datacenter \
  --size Standard_NV12 \
  --admin-username renderuser \
  --admin-password "SenhaForte123!" \
  --authentication-type password
```

---

### 🔐 5. Bastion Host (gerenciador de acesso seguro)
---

### 🛠️ 6. VM para Hospedagem de APIs / Backends (Node.js, Python, etc.)

```bash
az vm create \
  --resource-group MeuGrupo \
  --name VMApiBackend \
  --image UbuntuLTS \
  --size Standard_B2ms \
  --admin-username apidev \
  --generate-ssh-keys \
  --custom-data cloud-init-api.txt \
  --public-ip-sku Standard \
  --tags workload=api environment=dev
```

> 💡 Utilize `cloud-init-api.txt` para instalar Node.js, Python, PM2 ou outros serviços automaticamente.
> 🔒 Combine com NSG limitando a porta 80/443, ou configure com Azure Application Gateway.

Exemplo básico de `cloud-init-api.txt`:

```yaml
#cloud-config
package_update: true
packages:
  - nginx
  - nodejs
  - npm
runcmd:
  - mkdir /app
  - git clone https://github.com/seu-repo/backend-api.git /app
  - cd /app && npm install && npm start
```


```bash
az vm create \
  --resource-group MeuGrupo \
  --name BastionVM \
  --image UbuntuLTS \
  --size Standard_B2s \
  --admin-username bastion \
  --generate-ssh-keys \
  --public-ip-sku Standard \
  --nsg-rule SSH
```

> 💡 Combine com Azure Bastion para gerenciar acesso a outras VMs com segurança.


```bash
az network nic create \
  --resource-group MeuGrupo \
  --name customNIC \
  --vnet-name minhaVNet \
  --subnet minhaSubnet

az vm create \
  --resource-group MeuGrupo \
  --name VMComNIC \
  --nics customNIC \
  --image UbuntuLTS \
  --admin-username user \
  --generate-ssh-keys
```


```bash
az vm create \
  --resource-group MeuGrupo \
  --name MinhaVM \
  --image UbuntuLTS \
  --admin-username meuusuario \
  --generate-ssh-keys
```

---

### 🔗 3. Acessar a VM por SSH

```bash
az vm show --name MinhaVM --resource-group MeuGrupo -d --query publicIps -o tsv
ssh meuusuario@<IP-da-VM>
```

---

## 🧪 Explorando Outros Serviços via Terminal

### 🐳 Azure Container Instances (ACI)

```bash
az container create \
  --resource-group MeuGrupo \
  --name nginxcontainer \
  --image nginx \
  --dns-name-label nginxdemo \
  --ports 80
```

---

### 🗃️ Azure Storage (Blob)

```bash
az storage account create \
  --name meusdados \
  --resource-group MeuGrupo \
  --location eastus \
  --sku Standard_LRS
```

---

### 🔐 Azure Key Vault

```bash
az keyvault create --name MeuCofre --resource-group MeuGrupo
az keyvault secret set --vault-name MeuCofre --name "senhaBD" --value "supersecreta123"
```

---

### 🌐 Azure App Service (Web Apps)

```bash
az webapp up --name meuappweb --resource-group MeuGrupo --runtime "PYTHON:3.10"
```

---

### 📊 Azure Monitor + Log Analytics

```bash
az monitor log-analytics workspace create \
  --resource-group MeuGrupo \
  --workspace-name logsmeuapp
```

---

## 🧹 Limpando Recursos

```bash
az group delete --name MeuGrupo --no-wait --yes
```

---

## 🧠 Considerações Finais

- A Azure CLI permite controle total de recursos via terminal.
- Ideal para scripts, automações e infra como código.
- Service Principal + Key Vault = combo seguro e escalável.
- Vários serviços podem ser orquestrados em shell scripts ou pipelines CI/CD (ex: GitHub Actions, Azure DevOps).

---

## 🪄 Possíveis Expansões

- Integração com Terraform ou Bicep via CLI
- Teste de APIs do Azure Cognitive Services com `curl`
- Pipeline completo: CLI → Container → App Service → Monitor

---

## 📚 Referências

- [Documentação oficial da Azure CLI](https://learn.microsoft.com/pt-br/cli/azure/)
- [Azure Quickstart Templates](https://github.com/Azure/azure-quickstart-templates)
- [Guia de automação com Service Principal](https://learn.microsoft.com/en-us/cli/azure/create-an-azure-service-principal-azure-cli)

---

## 🐳 VM com Docker + NGINX + Backend
<!-- Exemplo de infraestrutura containerizada para backends com proxy reverso, usando cloud-init. -->

### ⚙️ Template: Backend containerizado com proxy reverso NGINX

```bash
az vm create \
  --resource-group MeuGrupo \
  --name VMBackendDocker \
  --image UbuntuLTS \
  --size Standard_B2ms \
  --admin-username dockeradmin \
  --generate-ssh-keys \
  --custom-data cloud-init-docker.txt \
  --public-ip-sku Standard \
  --tags workload=api environment=prod
```

Exemplo de `cloud-init-docker.txt`:

```yaml
#cloud-config
package_update: true
packages:
  - docker.io
  - docker-compose
runcmd:
  - systemctl start docker
  - systemctl enable docker
  - mkdir /app
  - curl -o /app/docker-compose.yml https://raw.githubusercontent.com/seu-repo/docker-backend/main/docker-compose.yml
  - docker-compose -f /app/docker-compose.yml up -d
```

---

## 🧱 Cluster com Azure VM Scale Set (VMSS)
<!-- Criação de clusters de VMs com escalabilidade automática baseada em carga. -->

### 🚀 Template de criação de cluster escalável

```bash
az vmss create \
  --resource-group MeuGrupo \
  --name ClusterApiVMSS \
  --image UbuntuLTS \
  --upgrade-policy-mode automatic \
  --admin-username clusteruser \
  --generate-ssh-keys \
  --custom-data cloud-init-api.txt \
  --instance-count 2 \
  --load-balancer ClusterLB
```

> 💡 Ideal para hospedar múltiplas instâncias de APIs com balanceamento automático.

### 🔄 Autoescalonamento baseado em CPU

```bash
az monitor autoscale create \
  --resource-group MeuGrupo \
  --resource ClusterApiVMSS \
  --resource-type Microsoft.Compute/virtualMachineScaleSets \
  --name autoScaleCluster \
  --min-count 2 \
  --max-count 10 \
  --count 2

az monitor autoscale rule create \
  --resource-group MeuGrupo \
  --autoscale-name autoScaleCluster \
  --condition "Percentage CPU > 70 avg 5m" \
  --scale out 1
```

---

## 🔄 Integração com Git e Deploy Automatizado (CI/CD)
<!-- Aborda boas práticas, automação via GitHub Actions e segurança com SSH. -->

### 🔐 Clonando repositórios Git com segurança (SSH)

> Antes de clonar repositórios privados, configure a chave SSH pública no GitHub/GitLab/Bitbucket.

```bash
# Gerar chave (caso ainda não tenha)
ssh-keygen -t rsa -b 4096 -C "azure-vm@meuprojeto"

# Adicionar chave ao ssh-agent
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa

# Clonar via SSH
git clone git@github.com:seu-usuario/seu-repo.git
```

Adicione sua chave pública (~/.ssh/id_rsa.pub) ao seu provedor Git remoto para autenticação sem senha.

---

### ⚙️ Configurando CI/CD com GitHub Actions para Azure VM

**1. Criar script de deploy na VM (ex: `deploy.sh`)**

```bash
#!/bin/bash
cd /app
git pull origin main
pm2 restart app
```

**2. Permitir acesso remoto via GitHub**

- Gere uma **chave SSH somente para o GitHub**
- Adicione a chave pública na `~/.ssh/authorized_keys` da VM

**3. Exemplo de GitHub Actions `.github/workflows/deploy.yml`**

```yaml
name: Deploy API to Azure VM

on:
  push:
    branches: [ "main" ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repo
        uses: actions/checkout@v3

      - name: Deploy via SSH
        uses: appleboy/ssh-action@v1.0.3
        with:
          host: ${{ secrets.VM_HOST }}
          username: azureuser
          key: ${{ secrets.VM_SSH_KEY }}
          script: |
            bash /home/azureuser/deploy.sh
```

> 📌 Salve `VM_HOST` e `VM_SSH_KEY` nos **Secrets** do repositório GitHub.

---

### 🛡️ Boas práticas de segurança na integração Git

- Use **chaves SSH separadas por projeto**
- Limite o acesso no `authorized_keys` com `command=""`, `from=""`
- Não use tokens pessoais diretamente em scripts
- Crie usuários específicos para CI/CD com permissão mínima

---


---

## 🗄️ Instâncias de Banco de Dados Gerenciado (Azure Database)

<!-- Exemplos de criação de instâncias de bancos de dados gerenciados na Azure como PostgreSQL e MySQL. -->

### 🐘 PostgreSQL Server Gerenciado

```bash
az postgres flexible-server create \
  --name meu-postgres-server \
  --resource-group MeuGrupo \
  --location eastus \
  --admin-user pgadmin \
  --admin-password SenhaForte123 \
  --sku-name Standard_B1ms \
  --version 13 \
  --storage-size 32 \
  --public-access 0.0.0.0
```

> 💡 Pode usar `--vnet` para restringir acesso à rede privada, ou configurar regras de firewall.

---

### 🐬 MySQL Server Gerenciado

```bash
az mysql flexible-server create \
  --name meu-mysql-server \
  --resource-group MeuGrupo \
  --location eastus \
  --admin-user mysqladmin \
  --admin-password SenhaForte123 \
  --sku-name Standard_B1ms \
  --version 8.0 \
  --storage-size 32 \
  --public-access 0.0.0.0
```

> 🔐 Lembre-se de configurar `--firewall-rule-name` para permitir o IP da sua máquina de acesso.

---

### 🔗 Conectando ao Banco de Dados a partir da VM

Exemplo com PostgreSQL:

```bash
sudo apt install postgresql-client -y
psql "host=meu-postgres-server.postgres.database.azure.com port=5432 dbname=postgres user=pgadmin@meu-postgres-server password=SenhaForte123 sslmode=require"
```

Exemplo com MySQL:

```bash
sudo apt install mysql-client -y
mysql -h meu-mysql-server.mysql.database.azure.com -u mysqladmin@meu-mysql-server -p
```

> 🔧 Para uso com backend em Docker, configure as variáveis `DB_HOST`, `DB_USER`, `DB_PASS` no `docker-compose.yml`.

---

---

## 📊 Monitoramento com Azure Monitor e Log Analytics

<!-- Demonstra como integrar VMs e bancos ao Azure Monitor para observabilidade avançada, e compara com métodos manuais de monitoramento. -->

### 🔍 Por que usar Azure Monitor?

Monitoramento manual (como rodar `top`, `htop`, ou scripts próprios em shell) oferece apenas **visão local e limitada**, exige manutenção constante e não escala bem.
Já o **Azure Monitor** oferece:

- Coleta automatizada de métricas e logs
- Análises em tempo real com Log Analytics
- Alertas configuráveis com base em condições específicas
- Integração com dashboards e ferramentas externas

---

### 📦 Habilitando Diagnóstico em uma VM

```bash
az monitor diagnostic-settings create \
  --name diagnosticoVM \
  --resource /subscriptions/SEU_ID/resourceGroups/MeuGrupo/providers/Microsoft.Compute/virtualMachines/MinhaVM \
  --workspace /subscriptions/SEU_ID/resourceGroups/MeuGrupo/providers/Microsoft.OperationalInsights/workspaces/meuLogAnalytics \
  --metrics '[{"category": "AllMetrics", "enabled": true}]' \
  --logs '[{"category": "Syslog", "enabled": true}]'
```

> 💡 **Por que esses parâmetros?**
> - `"AllMetrics"` ativa todas as métricas disponíveis (CPU, disco, rede etc)
> - `"Syslog"` permite capturar eventos do sistema para análise posterior
> - A vinculação a um **workspace** centraliza os dados para múltiplos recursos

---

### 🧠 Criando um Workspace Log Analytics

```bash
az monitor log-analytics workspace create \
  --resource-group MeuGrupo \
  --workspace-name meuLogAnalytics
```

---

### 📈 Criando Alertas Automáticos

```bash
az monitor metrics alert create \
  --resource-group MeuGrupo \
  --name AlertaCPUAlta \
  --scopes /subscriptions/SEU_ID/resourceGroups/MeuGrupo/providers/Microsoft.Compute/virtualMachines/MinhaVM \
  --condition "avg Percentage CPU > 85" \
  --description "Alerta de uso de CPU alto" \
  --severity 3
```

> 🚨 Você pode automatizar escalonamento, e-mails ou scripts com base nesses alertas.

---

### 🔎 Exemplo de Query KQL no Log Analytics

```kql
Perf
| where ObjectName == "Processor"
| where CounterName == "% Processor Time"
| summarize avg(CounterValue) by bin(TimeGenerated, 5m), Computer
```

> Essa consulta mostra o uso médio de CPU nos últimos intervalos de 5 minutos por máquina virtual.

---


---

## 📺 Dashboards Personalizados com Grafana + Notificações Externas

<!-- Mostra como usar Grafana com Log Analytics como fonte de dados e como configurar alertas visuais e notificações externas. -->

### 🖼️ Por que usar Grafana?

O Azure Monitor possui visualizações nativas, mas o **Grafana** permite:

- Dashboards altamente personalizados
- Painéis colaborativos com foco em usabilidade
- Integração com múltiplas fontes (ex: PostgreSQL, Redis, Azure Monitor)
- Suporte a notificações externas (Teams, Slack, Telegram etc.)

---

### 🧩 Conectando Azure Monitor (Log Analytics) ao Grafana

> O Grafana Cloud e o Grafana OSS (self-hosted) suportam Azure Monitor nativamente.

1. Instale o plugin Azure Monitor:

```bash
grafana-cli plugins install grafana-azure-monitor-datasource
```

2. Reinicie o serviço Grafana:

```bash
sudo systemctl restart grafana-server
```

3. Em “Configuration” → “Data Sources”, adicione:

- **Name:** AzureMonitor
- **Type:** Azure Monitor
- **Tenant ID, Client ID, Client Secret:** da sua app registrada no Azure AD
- **Subscription ID:** de onde estão os recursos monitorados

> 💡 Gere essas credenciais com `az ad sp create-for-rbac --name grafana-monitor` com permissão de leitura em monitoramento.

---

### 🧠 Exemplo de painel personalizado

- Gráfico de uso de CPU por VM
- Mapa de disponibilidade por região
- Tabela com falhas de login detectadas no Syslog
- Alertas visuais com limites de CPU/RAM/Disco

---

### 🔔 Configurando Notificações com Teams, Slack ou Telegram

1. Vá em **Alerting > Contact Points**
2. Adicione um novo canal (Slack, Teams, Telegram etc.)
3. Preencha com o Webhook gerado no app de destino

#### Exemplo: Webhook para Teams

1. Crie um canal no Teams → Conector Webhook
2. Copie o link gerado
3. Em Grafana → “Contact Points” → adicione esse link
4. Teste envio com um alerta simulado

---

### 🧭 Quando usar cada abordagem?

| Monitoramento | Melhor uso                                           |
|---------------|------------------------------------------------------|
| Azure Dashboards | Visualizações rápidas e nativas                   |
| Grafana         | Ambientes com múltiplas fontes e equipes diversas |
| Alertas nativos | Resposta automática e escalável                    |
| Notificações externas | Visibilidade em tempo real e resposta em equipe  |

---


---

## 🔧 Automação com DevOps: Pipelines, Backup e Segurança

<!-- Apresenta estratégias práticas de DevOps na Azure: pipelines automatizados, backup, hardening e boas práticas para ambientes de produção. -->

### 🔁 Automatizando Pipeline com Azure DevOps (YAML)

```yaml
# azure-pipelines.yml
trigger:
  branches:
    include:
      - main

pool:
  vmImage: 'ubuntu-latest'

steps:
  - task: UsePythonVersion@0
    inputs:
      versionSpec: '3.x'

  - script: |
      pip install -r requirements.txt
      pytest tests/
    displayName: 'Run Tests'

  - task: AzureCLI@2
    inputs:
      azureSubscription: 'MinhaConexaoAzure'
      scriptType: 'bash'
      scriptLocation: 'inlineScript'
      inlineScript: |
        az webapp restart --name MeuApp --resource-group MeuGrupo
```

> 📘 Use o Azure DevOps para CI/CD completo, integração com repositórios GitHub ou Azure Repos e logs centralizados.

---

### 💾 Backup Automatizado de VMs

```bash
az backup protection enable-for-vm \
  --resource-group MeuGrupo \
  --vault-name MeuRecoveryVault \
  --vm MeuServidor \
  --policy-name DefaultPolicy
```

**Outros comandos úteis:**

```bash
# Criar o cofre
az backup vault create --resource-group MeuGrupo --name MeuRecoveryVault --location eastus

# Listar backups
az backup item list --vault-name MeuRecoveryVault --resource-group MeuGrupo
```

> 💡 Configure políticas para retenção de backups, frequência e horário, via `az backup policy`.

---

### 🔐 Hardening de VMs (Boas Práticas de Segurança)

**1. Desabilite portas desnecessárias**
```bash
az network nsg rule create \
  --resource-group MeuGrupo \
  --nsg-name MinhaNSG \
  --name BloqueioGeral \
  --priority 100 \
  --direction Inbound \
  --access Deny \
  --protocol '*' \
  --source-address-prefix '*' \
  --destination-port-range 22 3389
```

**2. Use login por SSH com chave**
```bash
az vm create \
  --name MeuServidor \
  --resource-group MeuGrupo \
  --image Ubuntu2204 \
  --admin-username azureuser \
  --ssh-key-value ~/.ssh/id_rsa.pub
```

**3. Habilite atualização automática**
```bash
az vm update \
  --name MeuServidor \
  --resource-group MeuGrupo \
  --set osProfile.linuxConfiguration.patchSettings.patchMode=AutomaticByPlatform
```

---

### 🛡️ DevSecOps: Segurança como parte do ciclo

- Escaneie dependências com `dependabot`, `trivy`, `sonarcloud`
- Use Azure Defender for Cloud para insights automatizados de segurança
- Aplique “least privilege” (menor privilégio) para identidades e serviços
- Audite alterações com logs de atividade (`az monitor activity-log`)

---


---

## 🏗️ Provisionamento de Infraestrutura como Código (IaC)

<!-- Aborda como criar, versionar e gerenciar infraestrutura com Bicep e Terraform de forma eficiente e reprodutível. -->

### 🧱 Bicep — Linguagem nativa da Azure

**1. Exemplo de arquivo `main.bicep`:**

```bicep
param location string = 'eastus'
param vmName string = 'vmDemo'
param adminUsername string
param adminPassword string

resource vm 'Microsoft.Compute/virtualMachines@2022-08-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B1ms'
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: '20_04-lts'
        version: 'latest'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2022-09-01' = {
  name: '${vmName}-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: vnet.properties.subnets[0].id
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2022-09-01' = {
  name: '${vmName}-vnet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: ['10.0.0.0/16']
    }
    subnets: [
      {
        name: 'default'
        properties: {
          addressPrefix: '10.0.0.0/24'
        }
      }
    ]
  }
}
```

**2. Implantando:**

```bash
az deployment group create \
  --resource-group MeuGrupo \
  --template-file main.bicep \
  --parameters adminUsername=azureuser adminPassword=SenhaForte123
```

---

### 🌍 Terraform — Multi-cloud e declarativo

**1. Exemplo de estrutura:**

```hcl
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "principal" {
  name     = "MeuGrupoTerraform"
  location = "eastus"
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = "vmTF"
  resource_group_name = azurerm_resource_group.principal.name
  location            = azurerm_resource_group.principal.location
  size                = "Standard_B1ms"
  admin_username      = "azureuser"

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  network_interface_ids = [
    azurerm_network_interface.nic.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "20_04-lts"
    version   = "latest"
  }
}
```

**2. Implantando:**

```bash
terraform init
terraform plan
terraform apply
```

---

### 📊 Quando usar Bicep ou Terraform?

| Critério               | Bicep                        | Terraform                        |
|------------------------|------------------------------|----------------------------------|
| Suporte nativo Azure   | ✅ Sim                        | 🔄 Sim, via provedor             |
| Curva de aprendizado   | Baixa (para quem já usa Azure CLI) | Média                          |
| Multi-cloud            | ❌ Apenas Azure               | ✅ Sim                           |
| Ecossistema externo    | Médio                         | Amplo (módulos da comunidade)   |
| Velocidade de mudanças | Altíssima (Azure atualiza direto) | Média-alta                   |

---


---

## 🧩 Boas Práticas de Modularização de Código IaC

<!-- Aborda como estruturar projetos IaC com Bicep e Terraform de forma escalável, reutilizável e organizada. -->

### 📦 Por que modularizar?

- Facilita **reutilização** de código entre ambientes
- Torna a manutenção mais **simples e segura**
- Favorece **testes independentes** de componentes
- Melhora a **leitura e organização** do projeto

---

### 🧱 Modularização em Bicep

**📁 Estrutura de exemplo:**

```
infra/
├── main.bicep
├── modules/
│   ├── vm.bicep
│   └── network.bicep
```

**🔧 `main.bicep`:**

```bicep
module network 'modules/network.bicep' = {
  name: 'redePrincipal'
  params: {
    location: 'eastus'
  }
}

module vm 'modules/vm.bicep' = {
  name: 'vmPrincipal'
  params: {
    location: 'eastus'
    subnetId: network.outputs.subnetId
  }
}
```

**📄 `modules/network.bicep`:**

```bicep
param location string

resource vnet 'Microsoft.Network/virtualNetworks@2022-09-01' = {
  name: 'vnetModulo'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: ['10.0.0.0/16']
    }
    subnets: [
      {
        name: 'default'
        properties: {
          addressPrefix: '10.0.0.0/24'
        }
      }
    ]
  }
}

output subnetId string = vnet.properties.subnets[0].id
```

---

### 🌍 Modularização em Terraform

**📁 Estrutura:**

```
terraform/
├── main.tf
├── modules/
│   ├── vm/
│   │   └── main.tf
│   └── network/
│       └── main.tf
```

**🔧 `main.tf`:**

```hcl
module "network" {
  source   = "./modules/network"
  location = "eastus"
}

module "vm" {
  source     = "./modules/vm"
  location   = "eastus"
  subnet_id  = module.network.subnet_id
}
```

**📄 `modules/network/main.tf`:**

```hcl
variable "location" {}

resource "azurerm_virtual_network" "vnet" {
  name                = "modVnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = "MeuGrupo"
}

resource "azurerm_subnet" "subnet" {
  name                 = "subnetPadrao"
  resource_group_name  = "MeuGrupo"
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.0.0/24"]
}

output "subnet_id" {
  value = azurerm_subnet.subnet.id
}
```

---

### ✅ Boas práticas gerais

- 🔁 **Use variáveis com valores padrão**
- 📦 **Isolar recursos independentes** (ex: rede, storage, VMs)
- 🔐 **Nunca versionar secrets/senhas**
- 📚 Documente com comentários e `README.md` nos módulos
- 🔎 Teste módulos isoladamente com `terraform plan` ou `az deployment what-if`
- 📁 Nomeie pastas e arquivos com consistência

---


---

## 🧪 Gestão de Múltiplos Ambientes (Dev, Staging, Prod)

<!-- Explica o conceito e a prática de separar ambientes para ciclos de vida distintos de desenvolvimento, testes e produção em IaC -->

### 🎯 Por que usar múltiplos ambientes?

A separação de ambientes (como **desenvolvimento**, **homologação/staging** e **produção**) garante:

- **Isolamento de falhas** (um erro em dev não afeta a produção)
- **Testes seguros** antes do deploy definitivo
- **Ciclos de validação independentes**
- **Configurações e permissões específicas por ambiente**

---

### 🧱 Estrutura recomendada com Bicep

```
infra-bicep/
├── dev/
│   └── main.bicep
├── staging/
│   └── main.bicep
├── prod/
│   └── main.bicep
├── modules/
│   ├── vm.bicep
│   └── network.bicep
```

Cada pasta de ambiente possui um `main.bicep` que reutiliza os mesmos módulos, mas com parâmetros distintos:

```bicep
// dev/main.bicep
module vm 'modules/vm.bicep' = {
  name: 'vmDev'
  params: {
    location: 'eastus'
    environment: 'dev'
  }
}
```

O deploy pode ser feito com comandos específicos:

```bash
az deployment group create \
  --resource-group DevRG \
  --template-file dev/main.bicep
```

---

### 🌍 Estrutura recomendada com Terraform

```
terraform/
├── envs/
│   ├── dev/
│   │   └── main.tf
│   ├── staging/
│   │   └── main.tf
│   └── prod/
│       └── main.tf
├── modules/
│   └── ...
```

**Cada ambiente pode conter um `main.tf` com configurações separadas**:

```hcl
# envs/dev/main.tf
module "infra" {
  source   = "../../modules/infra"
  location = "eastus"
  env      = "dev"
}
```

Execute em cada ambiente separadamente:

```bash
cd envs/dev
terraform init
terraform apply
```

---

### 💡 Dicas práticas

- Use **nomes prefixados por ambiente** (ex: `vm-dev`, `vm-prod`)
- Separe os **grupos de recursos** para cada ambiente
- Defina **variáveis por ambiente** (`dev.tfvars`, `prod.tfvars`)
- Aplique políticas diferentes de segurança e logging por estágio
- Use **pipelines dedicados** para cada ambiente no Azure DevOps ou GitHub Actions

---


---

## ✅ Testes e Validação de Infraestrutura antes do Deploy

<!-- Explica como prever mudanças e validar infraestrutura com segurança usando ferramentas integradas e práticas recomendadas -->

### 🔍 Por que testar antes de aplicar?

Testar sua infraestrutura antes da criação real evita:

- Erros de configuração e sintaxe
- Impactos em recursos de produção
- Custos indesejados com recursos mal dimensionados
- Quebras de dependência entre componentes

---

### 🧪 Bicep + Azure CLI: `what-if`

```bash
az deployment group what-if \
  --resource-group MeuGrupo \
  --template-file main.bicep
```

**O que faz:**
Mostra uma previsão detalhada do que será criado, modificado ou destruído no ambiente Azure com base no template atual.

✅ Ideal para ambientes sensíveis
✅ Evita aplicar mudanças arriscadas por engano

---

### 🧪 Terraform: `plan` e `validate`

```bash
terraform validate
```

- Verifica se o código está sintaticamente correto.

```bash
terraform plan
```

- Mostra quais mudanças o Terraform irá aplicar.

**Exemplo de output:**

```
+ create azurerm_linux_virtual_machine.vm
~ modify azurerm_network_interface.nic
- destroy azurerm_public_ip.pip
```

✅ Revisão completa antes do `terraform apply`
✅ Ideal para revisões em PRs e automações CI/CD

---

### 🧠 Boas práticas de validação

- Automatize o uso de `plan` e `what-if` em pipelines
- Use revisão de código para alterações em IaC
- Valide parâmetros obrigatórios e tipos corretos
- Crie **ambientes temporários** para testes (com `destroy` agendado)
- Acompanhe recursos com o Azure Resource Graph ou o Portal

---

### 🛡️ Ferramentas adicionais

- **Checkov**: valida segurança e compliance no código IaC
- **Terrascan**: auditoria de infraestrutura como código
- **PSRule for Azure**: regras customizadas para padrões corporativos

---


---

## 🔁 Integração CI/CD para Deploys de Infraestrutura

<!-- Explica como automatizar a aplicação de infraestrutura como código com pipelines CI/CD -->

### ⚙️ Por que CI/CD para IaC?

- Automatiza testes e deploys seguros
- Garante consistência entre ambientes
- Permite rollback, versionamento e auditoria
- Reduz o risco de erro humano

---

### 🧱 Pipeline com Bicep (GitHub Actions)

```yaml
name: Deploy Bicep

on:
  push:
    branches: [ "main" ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Azure Login
        uses: azure/login@v1
        with:
          creds: ${{ secrets.AZURE_CREDENTIALS }}

      - name: Deploy Bicep
        run: |
          az deployment group create \
            --resource-group MeuGrupo \
            --template-file infra/main.bicep
```

---

### 🌍 Pipeline com Terraform (GitHub Actions)

```yaml
name: Terraform Apply

on:
  push:
    branches: [ "main" ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2

      - name: Terraform Init & Apply
        run: |
          terraform init
          terraform validate
          terraform plan
          terraform apply -auto-approve
```

---

## 🏷️ Padrões de Nomenclatura e Versionamento

<!-- Define boas práticas para manter a organização e rastreabilidade de recursos e código -->

### 🔤 Boas práticas de nomenclatura

- Use prefixos padronizados por ambiente (ex: `vm-dev`, `vm-prod`)
- Inclua tipo, localização e finalidade (ex: `app-eastus-backend01`)
- Evite nomes genéricos como `myVM`, `network1`

**Exemplo:**
```
rg-dev-core-weu-001
vm-prod-api-eastus-002
vnet-staging-internal-bra
```

---

### 🧾 Versionamento de infraestrutura

- Controle o código IaC com Git
- Use **branches por ambiente** (`main`, `staging`, `dev`)
- Tag versões principais de mudanças (`v1.0.0`, `v2.1.3`)
- Combine com changelogs (`CHANGELOG.md`) e descrição dos impactos

---

### 📘 Recomendações finais

- Documente o padrão em um arquivo `NAMING.md` no repositório
- Automatize validações de nomenclatura em pipelines com linters
- Revise periodicamente os padrões com o time

---

---

## 🛠️ Estratégias de Rollback e Recuperação de Falhas na Automação

<!-- Apresenta métodos e práticas para reverter mudanças ou recuperar ambientes em caso de falhas durante deploys de infraestrutura automatizados -->

### ⚠️ Por que planejar rollback?

Mesmo com testes e validação, falhas podem ocorrer:

- Mudanças não esperadas aplicadas em produção
- Interrupções em serviços críticos
- Erros humanos ou de automação

Planejar rollback e recuperação é essencial para resiliência e continuidade.

---

### 🔁 Estratégias de rollback com Terraform

#### 1. **Uso de versões anteriores no Git**

```bash
git checkout v1.2.0
terraform apply
```

- Reverte o estado da infraestrutura para um ponto anterior confiável.
- Combine com `terraform plan` para avaliar o impacto.

#### 2. **Terraform State Backup**

- O estado (`terraform.tfstate`) pode ser salvo em um backend remoto com versionamento (como Azure Blob Storage):

```hcl
backend "azurerm" {
  storage_account_name = "iacstate"
  container_name       = "tfstate"
  key                  = "prod.terraform.tfstate"
}
```

- Ative versionamento no container para recuperar estados anteriores se necessário.

---

### 🔁 Estratégias de rollback com Bicep

#### 1. **Desfazer via histórico de deployment**

```bash
az deployment group show --name NomeDoDeploymentAnterior
```

- Permite reaplicar o template anterior.

#### 2. **Snapshots e locks**

- Tire **snapshots manuais** de VMs ou discos críticos antes do deploy.
- Use **resource locks** para proteger recursos de exclusão acidental:

```bash
az lock create --name "ProtectVM" --lock-type CanNotDelete --resource-name MinhaVM --resource-type "Microsoft.Compute/virtualMachines" --resource-group MeuGrupo
```

---

### 🧩 Recomendações gerais

- Automatize backups de estado ou snapshots antes de aplicar mudanças
- Nunca aplique mudanças diretamente em produção sem validação prévia
- Use feature flags ou deployment slots para APIs e apps web
- Monitore falhas e reaja com alertas e planos de mitigação
- Documente playbooks de recuperação

---


---

## 📏 Monitoramento Automatizado de Conformidade

<!-- Apresenta o uso de Azure Policy e outras ferramentas para garantir que a infraestrutura siga padrões organizacionais e de segurança -->

### 🧭 O que é conformidade de infraestrutura?

Conformidade em infraestrutura garante que:

- Recursos sigam padrões de segurança e governança
- Configurações estejam alinhadas a regras corporativas
- Mudanças não violem políticas predefinidas

---

### 🛡️ Azure Policy

Azure Policy permite definir e aplicar regras em escala:

#### Exemplo: Restringir localizações de recursos

```bash
az policy definition create \
  --name restricao-localizacao \
  --rules policy.json \
  --params parameters.json \
  --display-name "Permitir apenas East US" \
  --mode All
```

```json
// policy.json
{
  "if": {
    "not": {
      "field": "location",
      "in": ["eastus"]
    }
  },
  "then": {
    "effect": "deny"
  }
}
```

#### Atribuir a política:

```bash
az policy assignment create \
  --policy restricao-localizacao \
  --scope /subscriptions/xxxxxx/resourceGroups/MeuGrupo
```

✅ Pode ser aplicado a subscriptions, grupos de recursos ou tenant
✅ Possui auditoria contínua e relatórios visuais no portal

---

### ⚙️ Azure Blueprints

- Conjuntos de políticas + templates ARM/Bicep + RBAC
- Útil para provisionar ambientes padronizados completos

---

### 🧾 Scripts manuais de verificação

Para cenários menores ou fora do Azure Policy, é possível usar scripts:

```bash
az resource list --query "[?location!='eastus']"
```

```bash
az vm list --query "[?storageProfile.osDisk.osType!='Linux']"
```

✅ Úteis para auditorias rápidas
✅ Podem ser usados em cron jobs ou pipelines
✅ Flexibilidade total via CLI, PowerShell ou Python (via SDK)

---

### 🔁 Integração com CI/CD e alertas

- Execute scripts de compliance nos pipelines
- Gere alertas via Log Analytics ou Azure Monitor
- Integre com Slack, Teams ou e-mail via Action Groups

---

### 🧠 Recomendações

- Comece com políticas de auditoria (`effect: audit`)
- Aplique regras restritivas apenas em produção
- Documente políticas em repositórios versionados
- Revise violações regularmente

---

---

## 🧯 # Automação de Alertas, Segurança e Resposta a Incidentes

### 🔐 # Por que integrar segurança na automação?

- Aumenta visibilidade sobre eventos críticos
- Permite resposta rápida a falhas e violações
- Reduz riscos com ações proativas e notificações em tempo real

---

### 📣 # Azure Monitor + Action Groups

```bash
az monitor metrics alert create \
  --name cpuHighAlert \
  --resource-group MeuGrupo \
  --scopes /subscriptions/.../resourceGroups/.../providers/Microsoft.Compute/virtualMachines/minhaVM \
  --condition "avg Percentage CPU > 80" \
  --window-size 5m --evaluation-frequency 1m \
  --action my-action-group
```

#### Ações possíveis:
- Notificar via Teams, Slack, e-mail, webhook
- Chamar uma Function ou Logic App para mitigar

---

### ⚠️ # Azure Security Center + Defender for Cloud

- Detecta vulnerabilidades, más configurações, exposição à internet
- Recomendado para ambientes com dados sensíveis e workloads críticos

---

### 🚨 # Integração com SIEM/SOAR

- Integração com Microsoft Sentinel (SIEM nativo)
- Criação de regras automatizadas para resposta
- Webhooks para sistemas externos (Zabbix, Splunk, PagerDuty)

---

## ✅ # Encerramento: Checklist de Boas Práticas e Fluxo Recomendado

### 📋 # Checklist

- [x] Login seguro e com identidade controlada
- [ ] Uso da CLI com escopos e automação
- [ ] Definição clara de ambientes (dev, staging, prod)
- [ ] Infraestrutura como código com versionamento
- [ ] Testes com `what-if` / `terraform plan`
- [ ] Deploy seguro com CI/CD
- [ ] Validação pós-deploy e rollback
- [ ] Monitoramento com Azure Monitor e Policy
- [ ] Conformidade automatizada
- [ ] Alertas, segurança e resposta ativa

---

### 🔄 # Fluxo Recomendado

1. Escreva o código da infraestrutura (Bicep/Terraform)
2. Teste localmente (`validate`, `what-if`, `plan`)
3. Versione no Git com revisão
4. Automatize deploys com CI/CD
5. Use políticas e scripts para garantir conformidade
6. Monitore e receba alertas automaticamente
7. Planeje rollback e documente incidentes
8. Evolua com feedback contínuo

---

### 💬 # Considerações Finais

A automação de infraestrutura com foco em terminal e segurança permite escalar com confiança. O domínio da CLI, junto com boas práticas de IaC, CI/CD e monitoramento, forma a base de uma operação moderna, segura e eficiente na nuvem Azure.
=======
# Teste GCP
# Teste GCP
# Atualização para teste de workflow
# Atualização para teste de workflow
>>>>>>> ab43c81839a015e2a4d0ee425c51f789842627a2
