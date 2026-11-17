# Plano de Implementação: Provisionamento de IAM User de Serviço para CI/CD

> **Decisão do Usuário**: Opção 1 - Criar IAM User de Serviço para CI/CD com Chaves Estáticas Permanentes
> **Status**: Aprovado para Execução

---

## 1. Contexto & Diagnóstico

As credenciais temporárias do fluxo `aws login` no modelo *New AWS Experience* baseiam-se em tokens OAuth com tempo de vida de 15 minutos (900 segundos). Enquanto a estação de desenvolvimento do desenvolvedor conta com um loop contínuo de refresh em segundo plano que renova esses tokens via refresh token, o GitHub Actions opera de forma autônoma com segredos estáticos (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN`).

Após a janela de 15 minutos, qualquer execução subsequente de esteira de CI/CD que dependa de `AWS_SESSION_TOKEN` expira, gerando a falha `The security token included in the request is expired`.

A simulação via `iam:SimulatePrincipalPolicy` confirmou que as Service Control Policies (SCPs) gerenciadas da organização permitem `iam:CreateUser`, `iam:CreateAccessKey` e `iam:AttachUserPolicy` (`AllowedByOrganizations: true`).

---

## 2. Ações de Implementação

### 2.1 Criação do Usuário de Serviço no IAM
- Criar o usuário IAM `github-actions-cicd` na conta `231268219488`.
- Anexar a política gerenciada `arn:aws:iam::aws:policy/AdministratorAccess`.
- Gerar o par de credenciais permanentes de acesso programático (`AKIA...`).

### 2.2 Atualização dos Segredos no GitHub Actions
- Atualizar os segredos em todos os repositórios do projeto (`15soat-phase4-iac-k8s`, `15soat-phase4-iac-db`, `15soat-phase4-iac-lamda`, `15soat-phase4-api-work-order`, `15soat-phase4-api-billing`, `15soat-phase4-api-exec`, `15soat-phase4-lib-commons`, `15soat-phase4-e2e`):
  - `AWS_ACCESS_KEY_ID` = Nova chave estática `AKIA...`.
  - `AWS_SECRET_ACCESS_KEY` = Nova chave secreta estática.
  - `AWS_REGION` = `us-east-2`.
  - Excluir o segredo `AWS_SESSION_TOKEN` (não mais aplicável para identidades permanentes).

### 2.3 Reexecução e Monitoramento do Pipeline
- Disparar a reexecução do pipeline do `15soat-phase4-iac-k8s` (`gh run rerun 44131563430` ou novo dispatch).
- Acompanhar a execução das etapas de Terraform (VPC, EKS Cluster, Node Group, Kong Ingress, Strimzi Kafka, Monitoring).
