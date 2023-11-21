# Crash Bandicoot Night Funkin' - Wumpa Engine - Modded OS Engine 

![](https://github.com/Bioxcis/Crash-Bandicoot-Night-Funkin-Mod/blob/d07d8cc8de600a080965a575f149261c5285a272/art/CBNF_Logo.png)

## Compilação:
You must have [the most up-to-date version of Haxe](https://haxe.org/download/), seriously, stop using 4.1.5, it misses some stuff.
Necessário ter [a versão mais atualizada do Haxe](https://haxe.org/download/), não use versões anteriores.

Follow a Friday Night Funkin' source code compilation tutorial, after this you will need to install LuaJIT.
Siga um tutorial de compilação do código-fonte do Friday Night Funkin', de preferencia o descrito [aqui](https://github.com/notweuz/FNF-OSEngine).

## Creditos Wumpa Engine:
* [Bioxcis](https://github.com/Bioxcis) - Codificação, Tradução, Artes e design

### Agradecimentos Especiais Wumpa Engine
* [Airumu](https://x.com/airumuu?s=20) - Crash Bandicoot modder, instrumentos originais (musicas) de Crash Bandicoot - PlayStation One Series

## Creditos OS Engine:
* [weuz_](https://github.com/notweuz) - Codificação
* [nelifs](https://github.com/nelifs) - Codificação e Design
* [Cooljer](https://github.com/cooljer) - Artes

### Agradecimentos Especiais OS Engine
* [jonnycat](https://github.com/McJonnycat) - Correção de bugs na Engine <3
* [Kade Engine](https://gamebanana.com/mods/44291) - Skin das Notas Circulares

## Creditos Psych Engine:
* Shadow Mario - Programador
* RiverOaken - Artista
* Yoshubs - Assistente Programador

### Agradecimentos Especiais Psych Engine
* bbpanzu - Ex-Programador
* shubs - Novo Sistema de Input
* SqirraRNG - Gerenciador de falhas e código base para a Waveform do Editor de Gráficos
* KadeDev - Corrigido alguns itens do Chart Editor e outros
* iFlicky - Compositor de Psync e Tea Time, responsável pelos sons originais dos Diálogos
* PolybiusProxy - .MP4 Video Loader Library (hxCodec)
* Keoiki - Animações de Splash das Notas
* Smokey - Suporte a Sprite Atlas
* Nebula the Zorua - LUA JIT Fork e alguns retrabalhos de Lua e código VCR Shader
_____________________________________

# Descrição

## Sobre a Wumpa Engine

Wumpa Engine é uma modificação da OS Engine em conjunto com a Psych Engine, então você pode usar quase todos os recursos da Psych Engine aqui!
Compatível com Scripts Lua atuais (Psych v0.5.2+ / OS v1.5.1).

## Caracteristicas

### Design dos menus
O Design e as animações dos menus do jogo foram editados e adicionados com características semelhantes aos jogos da franquia Crash Bandicoot.

### Traduções
Wumpa Engine está disponível em 3 linguas por padrão, traduzindo todos os menus e editores do jogo.
Languages: Português, Español, English.

![](https://github.com/Bioxcis/Crash-Bandicoot-Night-Funkin-Mod/blob/aad2dcdba91e0cf3523d9448a91b391f77406be4/art/CBNF_Menus.png)

### Novo Tamanho de HUD do jogo
Altera o zoom da HUD do jogo em uma escala um pouco menor para encaixar e adaptar melhor os ícones/contadores flutuantes das partidas.
Isso é funcional por meio dos Scripts em Lua!!! Não altera em nada o andamento do jogo no caso de ausência do Script.

![](https://media.discordapp.net/attachments/969211146412363828/969212761605296198/unknown.png?width=465&height=676)

### Novas músicas disponíveis
Novas músicas para o Menu Principal e para o Pause do jogo na temática de Crash Bandicoot.
Adaptação da música do menu Ajuste Delay de Nota e Combo Offset.

### Conquistas
Leve Modificação no sistema de Conquistas e adição de novas Conquistas do Mod vistas no menu Missões.

# Novas Mecânicas de Jogo
*Aviso: Diversas funcionalidades especiais do mod estão disponíveis apenas com o uso dos Scripts Lua*

## Notas Especiais

### Caixas
São 8 novas notas na forma de caixas que oferecem um desafio a mais ao jogo, possibilitando a coleta de certos itens do jogo.
Um item clássico e marcante que não pode faltar em um jogo do Crash.

### Wumpas
Uma nota especial e deliciosa que auxilia na saúde do jogador e necessária para obter itens especiais em determinado estilo de nível.
A comida favorita do nosso querido marsupial laranja.

## Eventos
Novos eventos disponíveis para uso.
* O evento 'Set CamZoom' é uma adaptação do evento de zoom original do jogo, porém dividido entre Game e HUD.
* O evento 'Text Event' permite você criar um texto com a fonte geral do jogo.
* O evento 'Dadbattle Spotlight' simula o efeito de holofotes visto em Dadbattle.

![](https://media.discordapp.net/attachments/969211146412363828/969218236950397038/unknown.png)
