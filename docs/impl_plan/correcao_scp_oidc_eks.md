# Plano de Implementação: Correção de Restrição SCP na Criação do OIDC Provider EKS

> **Decisão do Usuário**: Opção 1 - Desabilitar OIDC Provider / IRSA via Flag Parametrizada & Liberar Lock do DynamoDB
> **Status**: Aprovado para Execução

---

## 1. Contexto & Diagnóstico

Durante a execução da esteira de CI/CD do repositório `15soat-phase4-iac-k8s` (Workflow Run ID `44106050863`), a etapa de provisionamento do cluster EKS falhou com o erro:
`AccessDenied: ... iam:CreateOpenIDConnectProvider on resource: arn:aws:iam::231268219488:oidc-provider/... with an explicit deny in a service control policy: arn:aws:organizations::223259830116:policy/o-jqwtiq9tgg/service_control_policy/p-sypgg5kd`.

No modelo *AWS Projects / New AWS Experience*, a conta está sob a Service Control Policy (SCP) gerenciada `p-sypgg5kd`, que veta a criação de provedores de identidade IAM OIDC (`iam:CreateOpenIDConnectProvider`).

Como o cluster EKS utiliza `aws_iam_role.node_group` e `aws-auth`/access entries para autenticação das instâncias e os pods comunicam-se via intra-cluster secrets (dispensando IRSA), a criação do OIDC Provider é opcional e pode ser desativada com segurança. Além disso, a interrupção da esteira deixou um registro de lock órfão no DynamoDB (`fiap-phase4-tf-lock`) que deve ser liberado.

---

## 2. Ações de Implementação

### 2.1 Liberação do Lock no DynamoDB
- Remover o item `fiap-phase4-terraform-state/iac-k8s/terraform.tfstate` da tabela DynamoDB `fiap-phase4-tf-lock` na região `us-east-2`.

### 2.2 Parametrização do Recurso OIDC no Módulo EKS
- Em `modules/eks/variables.tf`:
  - Declarar a variável `enable_irsa` (tipo `bool`, default `false`).
- Em `modules/eks/main.tf`:
  - Atualizar a contagem de `data.tls_certificate.this` e `resource.aws_iam_openid_connect_provider.this` para:
    `count = (var.use_existing_lab_role || !var.enable_irsa) ? 0 : 1`.
- Em `modules/eks/outputs.tf`:
  - Tratar `oidc_provider_arn` para retornar `null` caso `enable_irsa` esteja inativo.
- No arquivo raiz `variables.tf`:
  - Adicionar `variable "enable_irsa"` com default `false`.
- No arquivo raiz `main.tf`:
  - Encaminhar `enable_irsa = var.enable_irsa` na chamada do `module "eks"`.

### 2.3 Formatação e Validação
- Executar `terraform fmt -recursive`.
- Submeter a alteração ao crivo do subagente `Code Reviewer Sentinel`.

### 2.4 Solicitação de Permissão para Commit & Push
- Apresentar o resultado e solicitar permissão explícita ao usuário para commit e push (conforme Diretriz Global #1).
