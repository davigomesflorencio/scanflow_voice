# ScanFlow Voice

ScanFlow Voice é um aplicativo móvel desenvolvido em Flutter que transforma texto em fala (Text-to-Speech) de alta qualidade. O app oferece flexibilidade permitindo que o usuário digite textos manualmente ou utilize a câmera para capturar textos de imagens e fotos através de reconhecimento óptico de caracteres (OCR).

## Funcionalidades

- **Síntese de Voz a partir de Texto:** Digite qualquer frase ou texto para convertê-lo em áudio.
- **Leitura de Imagens (OCR):** Tire fotos ou faça upload de imagens da galeria; o app extrai o texto contido na imagem e o converte em fala.
- **Vozes Realistas:** Integração com a API da ElevenLabs para gerar vozes naturais e expressivas.

## Tecnologias Utilizadas

- **Linguagem:** Dart
- **Framework:** Flutter
- **IA de Voz:** ElevenLabs API
- **Visão Computacional:** Google ML Kit (On-device Machine Learning)

## Dependências Principais

O projeto utiliza diversas bibliotecas do ecossistema Flutter para entregar suas funcionalidades:

- **`http`**: Utilizado para realizar requisições REST à API da ElevenLabs para síntese de áudio.
- **`google_mlkit_text_recognition`**: Pacote do Google ML Kit para Flutter, responsável pelo reconhecimento e extração de texto em imagens de forma offline e rápida.
- **`image_picker`**: Permite ao usuário tirar fotos com a câmera ou selecionar imagens da galeria do dispositivo.
- **`audioplayers`** (ou similar): Para a reprodução do áudio sintetizado recebido da API.

## Arquitetura e Padrões de Projeto

O projeto foi estruturado visando a manutenibilidade e a separação de responsabilidades:

### Service Pattern (Padrão de Serviço)

A lógica de comunicação com APIs externas e processamento pesado é isolada em classes de serviço dedicadas.

- Exemplo: `TtsService` encapsula toda a complexidade das chamadas HTTP para a ElevenLabs, expondo apenas métodos simples como `synthesize` para a camada de UI.

### Organização

- **Services:** Camada responsável pela integração de dados e lógica de negócios (ex: chamadas de API, processamento de OCR).
- **UI/Widgets:** Camada de apresentação responsável apenas por desenhar a tela e capturar interações do usuário.

## Como Executar

1. Clone este repositório.
2. Instale as dependências:
   ```bash
   flutter pub get
   ```
3. Configure sua chave de API da ElevenLabs no serviço apropriado.
4. Execute o projeto:
   ```bash
   flutter run
   ```
