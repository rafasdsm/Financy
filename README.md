# 💰 Financy: Gerenciamento Financeiro Pessoal

Financy é um aplicativo móvel simples e eficiente desenvolvido em Flutter para gerenciamento financeiro pessoal. Ele oferece uma solução de controle de orçamento totalmente offline, utilizando o banco de dados local Hive para armazenamento seguro e persistente de dados.

## 🌟 Funcionalidades

O aplicativo permite ao usuário manter um registro claro de suas finanças com as seguintes funcionalidades:

| Funcionalidade | Descrição |
|----------------|-----------|
| Autenticação Segura | Cadastro e Login de usuários com senhas criptografadas (SHA-256) para garantir a segurança dos dados pessoais. |
| Transações Recorrentes | Registro de Receitas e Despesas com definição de frequência (Diária, Semanal, Mensal). |
| Dashboard Mensal | Visualização instantânea do saldo total, total de receitas e despesas projetadas para o mês. |
| Análise Visual | Gráfico de Pizza (`fl_chart`) para exibir a distribuição percentual entre receitas e despesas. |
| Gerenciamento de Dados | Permite adicionar, listar e remover transações facilmente. |

## 🛠️ Tecnologias Utilizadas

* **Linguagem:** Dart
* **Framework:** Flutter
* **Banco de Dados Local:** Hive (e `hive_flutter`) - Um banco de dados NoSQL rápido e leve.
* **Gráficos:** fl_chart - Para a visualização do Gráfico de Pizza.
* **Criptografia:** crypto - Utilizado para hashing (SHA-256) de senhas.

## 📂 Estrutura do Projeto

O projeto segue uma arquitetura baseada em camadas (Apresentação e Serviço) para manter a separação de responsabilidades:

| Arquivo | Camada | Responsabilidade |
|---------|--------|------------------|
| `main.dart` | Inicialização | Inicializa o Hive e define o roteamento, verificando o status de login. |
| `storage_service.dart` | Serviço/Dados (Repository) | Gerencia a persistência de dados (CRUD de Transações) e a lógica de Autenticação (Login, Cadastro). |
| `models.dart` | Modelos | Definição dos modelos de dados (`Usuario`, `TransacaoModel`) e o enum `Frequencia`. |
| `models.g.dart` | Gerado | Adaptadores de tipo do Hive. |
| `login_screen.dart` | Apresentação | Interface para a tela de Login. |
| `cadastro_screen.dart` | Apresentação | Interface para a tela de Cadastro de novos usuários. |
| `home_screen.dart` | Apresentação/Lógica | Dashboard principal, cálculos financeiros (`_calcularTotais`), e listagem de transações. |

## 💡 Detalhes de Implementação

### Segurança (Autenticação)

As senhas dos usuários não são armazenadas em texto simples. O `StorageService` utiliza:

1. O pacote `crypto` para gerar um hash irreversível da senha com o algoritmo SHA-256 (`_hashSenha`).
2. O `Usuario` é salvo no Hive com este hash.
3. No login, a senha inserida é novamente hasheada e comparada com o hash armazenado.

### Lógica de Projeção Mensal

No `home_screen.dart`, a função `_calcularTotais` garante que o dashboard exiba um resumo mensal preciso, mesmo para transações recorrentes.

| Frequência (`Frequencia` Enum) | Multiplicador | Racional |
|--------------------------------|---------------|----------|
| `mensal` | `1` | Valor é somado diretamente. |
| `semanal` | `4` | Projeção de 4 semanas por mês. |
| `diaria` | `30` | Projeção de 30 dias por mês. |

O Saldo Total é calculado como: `Total de Receitas Mensais - Total de Despesas Mensais`.

## ⚙️ Como Instalar

Para rodar o projeto Financy localmente, siga os passos abaixo:

### Pré-requisitos

* Flutter SDK instalado.
* Um IDE configurado para Flutter (VS Code ou Android Studio).

### Passos

1. **Clone o repositório:**

```bash
git clone [https://docs.github.com/pt/repositories/creating-and-managing-repositories/about-repositories](https://github.com/rafasdsm/Financy.git)
cd financy
```

2. **Instale as dependências:**

```bash
flutter pub get
```

3. **Gere os adaptadores do Hive:** Como o projeto usa o Hive e os arquivos `models.g.dart` são gerados, você pode precisar rodar o build runner se houver modificações nos modelos:

```bash
flutter pub run build_runner build
```

4. **Execute o aplicativo:**

```bash
flutter run
```

O aplicativo será iniciado no dispositivo ou emulador conectado.
