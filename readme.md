# BankFlutter

Um aplicativo de banco digital desenvolvido com Flutter.

![Badge](https://img.shields.io/badge/Flutter-3.16.0-blue)
![Badge](https://img.shields.io/badge/Dart-3.0.0-blue)
![Badge](https://img.shields.io/badge/Status-Em%20Desenvolvimento-green)

## 📱 Sobre o Projeto

BankFlutter é um aplicativo para dispositivos móveis que simula as funcionalidades de um banco digital. O aplicativo permite que usuários realizem login, visualizem cotações de moedas em tempo real através de API, e realizem transferências entre contas.

## 🚀 Funcionalidades

- **Login seguro**: Autenticação com email/senha e biometria
- **Tela Principal**: Visualização de saldo e transações recentes
- **Cotação de Moedas**: Consulta de valores atualizados via API
- **Transferências**: Envio de valores para outros usuários
- **Recursos adicionais**: Compartilhamento de comprovantes, acesso à câmera para leitura de QR Code

## 🛠️ Tecnologias Utilizadas

- **Flutter**: Framework para desenvolvimento multiplataforma
- **Dart**: Linguagem de programação
- **Provider**: Gerenciamento de estado
- **HTTP Package**: Integração com APIs
- **Local Auth**: Autenticação biométrica
- **Share Plus**: Compartilhamento de conteúdo
- **Camera**: Acesso à câmera do dispositivo

## 📊 Telas do Aplicativo

### Tela de Login
- Campos para email e senha
- Botão de login
- Opção de autenticação biométrica

### Tela Principal
- Exibição de saldo
- Lista de transações recentes
- Menu de navegação para outras funcionalidades

### Tela de Cotação
- Lista de moedas com valores atualizados
- Gráfico de histórico de cotações
- Atualização em tempo real

### Tela de Transferência
- Seleção de destinatário
- Entrada de valor
- Confirmação e comprovante

## 🧩 Estrutura do Projeto

```
lib/
├── main.dart              # Ponto de entrada
├── routes/                # Configuração de rotas
├── models/                # Modelos de dados
├── screens/               # Telas do aplicativo
├── widgets/               # Componentes reutilizáveis
├── services/              # Serviços e integrações
└── utils/                 # Funções utilitárias
```

## 📋 Requisitos

- Flutter 3.0.0 ou superior
- Dart 2.17.0 ou superior
- Dispositivo ou emulador Android/iOS

## 🚀 Como Executar

1. Clone este repositório
```bash
git clone https://github.com/seu-usuario/bank-flutter.git
```

2. Navegue até o diretório do projeto
```bash
cd bank-flutter
```

3. Instale as dependências
```bash
flutter pub get
```

4. Execute o aplicativo
```bash
flutter run
```

## 📦 Gerando APK Otimizado

Para gerar um APK otimizado para produção:

```bash
flutter build apk --release --obfuscate --split-debug-info=build/app/outputs/symbols
```

O APK gerado estará disponível em:
```
build/app/outputs/flutter-apk/app-release.apk
```

## 📱 Rotas Nomeadas

O aplicativo utiliza sistema de rotas nomeadas para navegação entre telas:

- `/login` - Tela de login
- `/home` - Tela principal
- `/currency` - Tela de cotações
- `/transfer` - Tela de transferência
- `/transfer_confirm` - Confirmação de transferência (com argumentos)

## 🔌 Integração com API

A tela de cotações utiliza uma API externa para obter valores atualizados de moedas. A implementação usa o pacote HTTP para realizar requisições e processar as respostas.

## 🧪 Funcionalidades para Implementação Futura

- Suporte a temas claro/escuro
- Múltiplos idiomas
- Modo offline
- Notificações push
- Pagamento via QR Code

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

---

Desenvolvido como projeto acadêmico para a disciplina de Desenvolvimento Mobile com Flutter.