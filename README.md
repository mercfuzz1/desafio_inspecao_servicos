# Field Inspection — Flutter

Aplicativo Android desenvolvido para o desafio técnico de Desenvolvedor Mobile Flutter, com foco em inspeções de campo, persistência local e sincronização offline.

## 1. Instalação e execução da API mock

### Pré-requisitos

* Flutter SDK `3.47.0` — canal `stable`
* Dart SDK `3.13.0` — incluído no Flutter
* Android Studio
* Android SDK `37.0.0`
* Node.js — versão LTS
* npm

### Instalar dependências do Flutter

Na raiz do projeto:

```bash
flutter pub get
```

### Subir a API mock

Entre na pasta da API:

```bash
cd mock-api
```

Instale as dependências:

```bash
npm install
```

Inicie o servidor conforme as instruções disponíveis em `mock-api/README.md`.

## 2. Como rodar o app

Com a API mock em execução, conecte um dispositivo Android ou inicie um emulador.

Verifique os dispositivos disponíveis:

```bash
flutter devices
```

Execute o aplicativo:

```bash
flutter run
```

Para gerar o APK:

```bash
flutter build apk
```

### URL da API

Para execução no emulador Android, o aplicativo utiliza:

```text
http://10.0.2.2:3000
```

O endereço `10.0.2.2` permite que o emulador Android acesse o `localhost` da máquina onde a API mock está sendo executada.

Para um dispositivo físico, o endereço deve ser alterado para o IP da máquina na rede local.

O aplicativo foi desenvolvido com foco exclusivo na plataforma Android.

## 3. Arquitetura escolhida

Foi utilizada uma arquitetura baseada em **Clean Architecture**, organizada por features e separando responsabilidades entre apresentação, domínio e dados.

### Estrutura

```text
lib/
├── core/
│   ├── connectivity/
│   ├── database/
│   ├── network/
│   ├── storage/
│   └── theme/
│
└── features/
    ├── auth/
    ├── work_orders/
    ├── inspections/
    └── sync/
```

Cada feature possui suas próprias camadas:

```text
presentation/
├── pages/
├── widgets/
└── bloc/

domain/
├── entities/
├── repositories/
└── services/

data/
├── datasources/
└── repositories/
```

### Gerenciamento de estado

O gerenciamento de estado utiliza **BLoC**, incluindo:

* `AuthBloc`
* `WorkOrdersBloc`
* `InspectionFormBloc`
* `InspectionsHistoryBloc`
* `SyncBloc`

### Persistência local

Foi utilizado **Drift** como banco de dados local.

A escolha do Drift foi feita principalmente pela necessidade de persistência estruturada e confiável das inspeções e da fila de sincronização.

O Drift oferece:

* Banco SQLite local.
* Consultas tipadas.
* DAOs para separar as operações de persistência.
* Geração de código para tabelas e DAOs (Codegen.)
* Persistência dos dados mesmo após o encerramento do aplicativo.
* Boa integração com Dart e Flutter.

Para este desafio, o banco local é responsável principalmente por armazenar as inspeções, seus estados de sincronização, mensagens de erro e identificadores utilizados no processo de sync.

O token de autenticação é armazenado separadamente de forma segura através do `SecureStorage`, não sendo armazenado no banco de inspeções.

## 4. Como funciona a fila de sincronização

As inspeções são armazenadas localmente antes de serem enviadas para a API.

Cada inspeção possui um `clientId` (UUID) gerado no dispositivo. Esse identificador permanece o mesmo durante todo o ciclo de vida da inspeção e também durante novas tentativas de sincronização.

Os estados possíveis são:

* `draft` — rascunho
* `pending` — aguardando sincronização
* `synced` — sincronizada com sucesso
* `failed` — falha na sincronização

### Rascunho

Uma inspeção salva como `draft` permanece somente no banco local e não é enviada para a API.

### Conclusão da inspeção

Ao concluir uma inspeção, ela é armazenada localmente como `pending` e fica disponível para sincronização.

### Sincronização

A sincronização pode ser iniciada:

* Manualmente pelo botão de sincronização.
* Automaticamente quando a conectividade é recuperada.

Fluxo:

```text
pending / failed
       ↓
POST /inspections
       ↓
   sucesso?
   ↙     ↘
 sim      não
 ↓         ↓
synced    failed
```

Quando o envio é realizado com sucesso:

* O status local passa para `synced`.
* O `serverId` retornado pela API é armazenado.
* O erro anterior é removido.
* A interface é atualizada.

Quando ocorre uma falha:

* A inspeção permanece disponível para sincronização.
* O status passa para `failed`.
* O erro é armazenado de forma legível.
* Itens `failed` podem ser reenviados através da ação de retry.

O mesmo `clientId` é reutilizado nas novas tentativas de sincronização, evitando a criação de registros duplicados no servidor.

A tela de histórico permite visualizar o estado de sincronização das inspeções e realizar novas tentativas para itens que falharam.

## 5. Envio da foto

A API recomenda `multipart/form-data`, mas o contrato também disponibiliza uma alternativa através de JSON utilizando `photoBase64`.

Neste projeto foi utilizada a **alternativa JSON com Base64**, por ser suficiente para o escopo do desafio e simplificar o fluxo de persistência e sincronização offline.

O fluxo da foto é:

```text
Câmera
  ↓
Arquivo JPG local
  ↓
Redimensionamento/compressão
  ↓
Leitura dos bytes
  ↓
Conversão para Base64
  ↓
JSON
  ↓
POST /inspections
```

A captura da imagem utiliza parâmetros para limitar o tamanho do arquivo:

```dart
imageQuality: 80,
maxWidth: 1280,
```

Durante a sincronização, o arquivo local é convertido para Base64 e enviado no campo:

```json
{
  "photoBase64": "<base64 da imagem>"
}
```

Essa abordagem segue a alternativa prevista no contrato da API.

Como melhoria futura, o envio poderia ser migrado para `multipart/form-data`, que é o formato recomendado pelo contrato e mais adequado para uploads de arquivos maiores.

## 6. O que ficou pendente / o que faria com mais tempo

Como melhorias futuras, seriam possíveis:

* Adicionar mais testes unitários e de BLoC para autenticação, Work Orders e formulário.
* Implementar campos dinâmicos através de `GET /work-orders/:id/form-schema`.
* Migrar o upload da foto de Base64 para `multipart/form-data`.
* Melhorar o tratamento centralizado das diferentes categorias de erro HTTP e Dio.
* Implementar CI para validação automática, análise estática e execução dos testes.
* Refinar ainda mais a experiência de uso outdoor, incluindo acessibilidade, contraste e áreas de toque.
* Refinar validação de campos de login e criação de inspeção.
* Implementar uma estratégia de sincronização mais avançada para grandes volumes de inspeções.
* Melhorar as ramificações da pipeline.

## 7. Decisões e limitações conhecidas

O projeto prioriza os requisitos principais do desafio: arquitetura organizada, persistência local, funcionamento offline, fila de sincronização e tratamento de estados.

Algumas funcionalidades foram deliberadamente mantidas fora do escopo para evitar complexidade desnecessária, como mapas avançados, campos dinâmicos, CI e upload multipart.

A utilização de Base64 para as fotos segue a alternativa prevista no contrato da API. Para um cenário de produção com maior volume de imagens, o uso de `multipart/form-data` seria preferível por reduzir o overhead causado pela codificação Base64.
