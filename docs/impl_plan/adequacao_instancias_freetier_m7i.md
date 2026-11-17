# Plano de Implementação: Adequação de Instâncias EKS ao AWS Free Tier (m7i-flex.large)

> **Decisão do Usuário**: Opção 1 - Adotar m7i-flex.large Elegível para Free Tier & Limpar Node Group Falho
> **Status**: Aprovado para Execução

---

## 1. Contexto & Diagnóstico

Durante a execução da esteira de CI/CD do repositório `15soat-phase4-iac-k8s`, a etapa de provisionamento do EKS Node Group falhou com o erro:
`InvalidParameterCombination - The specified instance type is not eligible for Free Tier. For a list of Free Tier instance types, run 'describe-instance-types' with the filter 'free-tier-eligible=true'. Launching EC2 instance failed.`

A configuração anterior especificava `t3a.large` (instâncias baseadas em AMD), que não são elegíveis no modelo de contas Free Tier da AWS. A tentativa de recriação subsequente retornou `ResourceInUseException` devido ao Node Group ter permanecido em estado `CREATE_FAILED` no plano de controle do EKS.

A consulta à API do Amazon EC2 identificou que a família `m7i-flex.large` (x86_64, 2 vCPUs, 8 GiB RAM) é elegível para Free Tier na região `us-east-2`, fornecendo a mesma capacidade de memória do tipo anterior e garantindo a estabilidade de workloads pesadas (Kafka Strimzi, Kong Ingress, microsserviços Spring Boot).

---

## 2. Ações de Implementação

### 2.1 Limpeza do Node Group com Falha no AWS EKS
- Executar `aws eks delete-nodegroup` para desalocar o Node Group `fiap-workshop-eks-default-ng` e seu Auto Scaling Group associado.
- Aguardar até que a remoção seja concluída pelo control plane do EKS.

### 2.2 Atualização da Configuração de Tipo de Instância no Terraform
- No arquivo `variables.tf` (raiz):
  - Alterar o default de `node_instance_types` para `["m7i-flex.large"]`.
- No arquivo `modules/eks/variables.tf`:
  - Alterar o default de `node_instance_types` para `["m7i-flex.large"]`.

### 2.3 Formatação e Validação do Terraform
- Executar `terraform fmt -recursive`.
- Executar `terraform validate`.
- Submeter a alteração ao crivo do subagente `Code Reviewer Sentinel`.

### 2.4 Solicitação de Permissão para Commit & Push
- Apresentar o resultado e solicitar permissão explícita ao usuário para commit, push e abertura/merge do PR (conforme Diretriz Global #1).
