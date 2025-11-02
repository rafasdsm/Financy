# Financy
📚 Documentação do Projeto "Financy"

O projeto Financy é um aplicativo de gerenciamento financeiro pessoal desenvolvido em Flutter. Ele utiliza o Hive como banco de dados NoSQL local para persistência de dados, garantindo que as informações do usuário (contas e transações) sejam armazenadas de forma segura e offline.

🚀 Funcionalidades Principais

O aplicativo foi desenvolvido para ser intuitivo e eficiente no controle de receitas e despesas:

Autenticação Local:

Cadastro de novos usuários.

Login seguro com senha criptografada (SHA-256).

Verificação do estado de login na inicialização (main.dart).

Gerenciamento de Transações:

Adição de transações (Receita ou Despesa) com nome, valor e frequência (diária, semanal, mensal).

Listagem de todas as transações do usuário logado.

Remoção de transações via botão ou gesto de swipe na lista.

Resumo Financeiro Mensal:

Cálculo do saldo total, total de receitas e total de despesas, projetando as transações diárias/semanais para um valor mensal.

Visualização da distribuição de receitas vs. despesas através de um Gráfico de Pizza (fl_chart).

🛠️ Estrutura do Código

Arquivo

Descrição

Componentes/Classes Chave

main.dart

Ponto de entrada do aplicativo. Inicializa o Hive e define o roteamento, direcionando para a tela correta com base no status de login.

main(), FinanceApp

storage_service.dart

Camada de Serviço (Repository) para todas as operações de banco de dados (Hive). Contém a lógica de autenticação e manipulação de transações.

StorageService, init(), cadastrarUsuario(), login(), _hashSenha()

models.dart

Definição dos modelos de dados utilizados no Hive.

Usuario, TransacaoModel, Frequencia (enum)

models.g.dart

Arquivo gerado automaticamente pelo hive_generator que contém os adaptadores de tipo necessários para o Hive persistir os modelos.

UsuarioAdapter, TransacaoModelAdapter

login_screen.dart

Tela de interface para o usuário acessar a conta.

LoginScreen

cadastro_screen.dart

Tela de interface para o registro de um novo usuário.

CadastroScreen

home_screen.dart

Tela principal (Dashboard) do aplicativo. Contém a lógica de cálculo financeiro, o gráfico e a lista de transações.

HomeScreen, _buildPieChartCard(), _calcularTotais()

🔒 Detalhes de Implementação

1. Persistência e Segurança (storage_service.dart)

O aplicativo utiliza o pacote hive_flutter para armazenamento local.

Autenticação: A segurança é garantida pela criptografia da senha.

Algoritmo: Utiliza SHA-256 do pacote crypto para transformar a senha bruta em um hash irreversível (_hashSenha(String senha)).

O login é validado comparando o hash da senha inserida com o hash armazenado no Usuario.

Controle de Sessão: O e-mail do usuário logado é armazenado na box current_user do Hive para manter o estado da sessão entre as execuções do app.

Isolamento de Dados: Todas as transações são salvas com um campo userId (o e-mail do usuário). O método getTransacoesDoUsuario() filtra as transações, garantindo que cada usuário veja apenas seus próprios dados.

2. Lógica de Cálculo Mensal (home_screen.dart)

Para criar um resumo financeiro útil, o HomeScreen projeta as transações recorrentes para um valor mensal:

A função de cálculo (_calcularTotais) itera sobre todas as transações, aplicando os seguintes fatores de multiplicação baseados no enum Frequencia (0=diaria, 1=semanal, 2=mensal):

Frequência

Fator de Multiplicação

Racional

Mensal (2)

1

O valor é somado diretamente.

Semanal (1)

4

Projeção de 4 semanas por mês.

Diária (0)

30

Projeção de 30 dias por mês.

O saldoTotal é calculado como totalReceitasMensais - totalDespesasMensais.

3. Gerenciamento de Estado e Reatividade

O Hive, por ser um banco de dados reativo, permite que os widgets sejam atualizados automaticamente. No entanto, o HomeScreen utiliza setState após cada operação de CRUD (_adicionarTransacao, _removerTransacao) e no _carregarTransacoes (chamado em initState) para recarregar a lista e os cálculos do dashboard.
