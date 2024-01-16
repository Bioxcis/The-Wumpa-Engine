# Crash Bandicoot Night Funkin' - Wumpa Engine - Modded OS Engine 

![](https://github.com/Bioxcis/Crash-Bandicoot-Night-Funkin-Mod/blob/34f9d3d74019d5cdf0ca5dda69526c6dffff733f/art/CBNF_wumpaEngine.png)

## Compilação:
Necessário ter [a versão mais atualizada do Haxe](https://haxe.org/download/), não use outras versões.

Follow a Friday Night Funkin' source code compilation tutorial, after this you will need to install LuaJIT.
Siga um tutorial de compilação do código-fonte do Friday Night Funkin', de preferencia o descrito [aqui](https://github.com/notweuz/FNF-OSEngine).

To Compile, use this on a Command prompt/PowerShell:

1. Install actuate: `haxelib install actuate 1.9.0`
2. Install discord_rpc: `haxelib install https://github.com/discord/discord-rpc.git`
3. Install flixel: `haxelib install flixel 4.11.0`
4. Install flixel-addons: `haxelib install flixel-addons 2.12.0`
5. Install flixel-demos: `haxelib install flixel-demos 2.9.0`
6. Install flixel-templates: `haxelib install flixel-templates 2.6.6`
7. Install flixel-tools: `haxelib install flixel-tools 1.5.1`
8. Install flixel-ui: `haxelib install flixel-ui 2.5.0`
9. Install hscript: `haxelib install hscript 2.5.0`
0. Install hxCodec/Video support: `haxelib install hxCodec 2.5.1`
1. Install hxcpp: `haxelib install hxcpp 4.2.1`
2. Install lime-samples: `haxelib install lime-samples 7.0.0`
3. Install lime: `haxelib install lime 8.0.0`
4. Install LuaJIT: `haxelib git linc_luajit https://github.com/nebulazorua/linc_luajit`
5. Install newgrounds: `haxelib install newgrounds 2.0.1`
6. Install openfl-webm: `haxelib install openfl-webm 0.0.4`
7. Install openfl: `haxelib install openfl 9.2.0`
8. Install polymod: `haxelib install polymod`

## Creditos Wumpa Engine:
* [Bioxcis](https://github.com/Bioxcis) - Codificação, Composição, Artes, Design e Efeitos Especiais

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
