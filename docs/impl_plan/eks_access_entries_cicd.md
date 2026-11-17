# Plano de Implementação: Configuração de EKS Access Entries para CI/CD

> **Decisão do Usuário**: Opção 1 - Habilitar EKS Access Entries e Conceder Permissão Admin ao github-actions-cicd
> **Status**: Aprovado para Execução

---

## 1. Contexto & Diagnóstico

Durante a transição da Fase 1 (provisionamento de VPC e EKS) para a Fase 2 (provisionamento de namespaces, Kong Ingress e Apache Kafka Strimzi) na esteira do GitHub Actions (`15soat-phase4-iac-k8s`), os recursos do provider `kubernetes` falharam com:
`Error: Unauthorized with kubernetes_namespace.workshop`

O cluster EKS foi provisionado inicialmente com o modo de autenticação padrão `CONFIG_MAP`, concedendo acesso exclusivo de `system:masters` ao criador inicial (`AccountFullAccessRole`). Ao executar a esteira com o novo IAM User de automação (`arn:aws:iam::231268219488:user/github-actions-cicd`), a API do Kubernetes rejeitou as requisições por falta de mapeamento de autorização RBAC.

A solução recomendada pela AWS para EKS 1.30+ é a ativação do modo `API_AND_CONFIG_MAP` e o registro de uma EKS Access Entry associada à política `AmazonEKSClusterAdminPolicy`.

---

## 2. Ações de Implementação

### 2.1 Habilitação do Modo de Autenticação no Cluster EKS
- Executar `aws eks update-cluster-config` definindo `--access-config authenticationMode=API_AND_CONFIG_MAP`.
- Aguardar a conclusão da atualização no plano de controle do EKS.

### 2.2 Criação da Access Entry para o IAM User de CI/CD
- Criar a Access Entry padrão (`STANDARD`) para o principal `arn:aws:iam::231268219488:user/github-actions-cicd`.
- Associar a política de cluster `arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy` com escopo `cluster`.

### 2.3 Codificação Declarativa no Terraform
- No arquivo `modules/eks/main.tf`:
  - Adicionar o bloco `access_config` dentro de `aws_eks_cluster.this` com `authentication_mode = "API_AND_CONFIG_MAP"` e `bootstrap_cluster_creator_admin_permissions = true`.
  - Declarar os recursos `aws_eks_access_entry.cicd` e `aws_eks_access_policy_association.cicd`.
- Executar `terraform fmt -recursive` e `terraform validate`.

### 2.4 Quality Gate & Permissão para Commit/Push
- Submeter o código ao crivo do subagente `Code Reviewer Sentinel`.
- Apresentar o resultado e solicitar permissão explícita ao usuário para commit, push e abertura/merge do PR (conforme Diretriz Global #1).
