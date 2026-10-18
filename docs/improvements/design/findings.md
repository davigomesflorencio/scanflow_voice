# Melhorias de design escolhidas

**1. Mostrar as novidades depois de uma atualização**

Depois de uma atualização, o usuário abre o app e nada diz o que mudou. O bug que você corrigiu e o recurso que ele pediu passam despercebidos. Mostre as novidades em uma lista na primeira vez que o app abrir após a atualização. Assim, quem relatou o bug ou pediu o recurso sabe que foi ouvido.

Link: https://flutterpro.design/details/md/in-app-changelog

**2. Não deixar a barra de navegação do sistema cobrir o fim das listas roláveis**

O último item das listas roláveis fica escondido pela barra de navegação do sistema. Deixe no fim da lista um espaço da altura dessa barra, para o último item ter folga em relação a ela.

Link: https://flutterpro.design/details/md/safe-area-replacement

**3. Usar as cores do app na seleção de texto**

O `MaterialApp` aplica cores padrão na seleção de texto dos campos. Troque por cores da sua marca.

Link: https://flutterpro.design/details/md/selection-color

**4. Pré-carregar imagens e ícones para não aparecerem de repente**

O Flutter só carrega imagens e ícones na memória quando um widget pede por eles, e decodificar leva tempo. Por isso eles aparecem alguns quadros atrasados. Pré-carregue tudo na tela de abertura, para que já estejam prontos na hora de desenhar.

Link: https://flutterpro.design/details/md/precache-icons

**5. Mostrar o progresso enquanto o Flutter web carrega**

O Flutter web leva alguns segundos para iniciar, e o usuário fica olhando uma página em branco, achando que o site quebrou. Mostre uma tela de abertura ou uma barra de progresso, para ele saber que o app está chegando.

Link: https://flutterpro.design/details/md/flutter-web-loading-progress

**6. Adicionar vibração (feedback háptico) nos momentos importantes**

O app parece sem vida quando toques e resultados acontecem em silêncio. Uma vibração sutil ao trocar de aba, ao enviar algo com sucesso ou ao mostrar um erro faz o app parecer responsivo na mão.

Link: https://flutterpro.design/details/md/haptic-feedback

**7. Usar algarismos de largura fixa em números que mudam**

Na maioria das fontes os dígitos têm larguras diferentes, então um cronômetro ou contador fica "pulando" enquanto muda. Algarismos tabulares deixam todos os dígitos com a mesma largura: os números ficam parados e alinhados.

Link: https://flutterpro.design/details/md/tabular-figures

**8. Dar um card de pré-visualização aos links do Flutter web**

Compartilhado no WhatsApp, Slack ou X, o link do app aparece só como um endereço solto. Ele deveria mostrar um card de pré-visualização com título, descrição e imagem.

Link: https://flutterpro.design/details/md/flutter-web-og-image

**9. Fechar o teclado quando o usuário rolar a tela**

O usuário termina de digitar e rola para ver o resto, mas o teclado continua cobrindo metade da tela. Rolar a tela significa que ele terminou de usar o campo, então feche o teclado por ele.

Link: https://flutterpro.design/details/md/dismiss-keyboard-on-scroll

**10. Mostrar a versão do app nas configurações**

Quando o usuário relata um bug, a primeira pergunta é qual versão ele está usando, e o app não tem onde mostrar isso.

Link: https://flutterpro.design/details/md/show-app-version

**11. Mostrar barras de rolagem nas telas roláveis**

A barra de rolagem mostra ao usuário onde ele está na tela e quanto falta.

Link: https://flutterpro.design/details/md/scrollbars

**12. Limitar o aumento do texto para o layout não quebrar**

Alguns usuários aumentam o tamanho do texto do aparelho por acessibilidade, e em escalas altas o layout transborda e quebra. Depois da correção, rode o app no limite definido para confirmar que nada quebra.

Link: https://flutterpro.design/details/md/text-scale-factor

**13. Mostrar uma tela amigável quando um widget falhar**

Quando um widget falha ao ser montado, na versão de produção o usuário vê uma caixa cinza vazia. Mostre uma mensagem amigável como "Algo deu errado", nas cores do app.

Link: https://flutterpro.design/details/md/friendly-error-view
