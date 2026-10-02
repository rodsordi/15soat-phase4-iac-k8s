# Infraestrutura de Plataforma Kubernetes EKS (`15soat-phase4-iac-k8s`)

Módulos Terraform para provisionamento da plataforma gerenciada Kubernetes de produção (AWS EKS 1.30), responsável por hospedar os microsserviços da oficina mecânica do Tech Challenge da Fase 4 da pós-graduação em Software Architecture (SOAT) da FIAP.

## Componentes da Plataforma
- **Cluster AWS EKS (1.30)**: Node group gerenciado com auto-scaling automático (2 a 5 nós, tipo de instância `t3a.large`), suporte a IAM Roles for Service Accounts (IRSA) e provedor OIDC integrado.
- **VPC & Subnets Dedicadas**: Arquitetura multi-AZ com subnets públicas e privadas, NAT Gateway de alta disponibilidade e tagging para provisionamento de Elastic Load Balancers (ELB).
- **Kong Ingress Controller**: Implantado via Helm chart oficial (`kong/kong`) e configurado como AWS Network Load Balancer (NLB) para atuar como API Gateway Ingress.
- **Cluster Apache Kafka (KRaft)**: Provisionado via Strimzi Kafka Operator em modo KRaft nativo (zero dependência do Apache ZooKeeper), provendo streaming de eventos para a coreografia da Saga.
- **Observabilidade Unificada (New Relic)**: Implantado via Helm chart `nri-bundle`, integrando coletores de métricas do OpenTelemetry, Prometheus e Kube-state-metrics.

## Arquitetura & Governança
- **Conformidade Estrita com GitOps**: Zero drift manual de infraestrutura (comandos `terraform apply` executados exclusivamente via pipelines automatizadas de CI/CD).
- **Diretriz de Segurança**: Proibição terminante de mutações manuais, tunelamentos (`kubectl port-forward`, `kubectl proxy`) ou execuções interativas em pods remotos de produção.
- **Gestão Segura de Credenciais**: Todos os segredos gerenciados e injetados via AWS Secrets Manager e criptografia KMS.

## Validação Sintática e de Conformidade
```bash
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
```
