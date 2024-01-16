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

Wumpa Engine é uma modificação da OS Engine em conjunto com a Psych Engine, então você pode usar quase todos os recursos da Psych Engine 0.7 aqui!
Compatível com Scripts Lua atuais (Psych v0.5.2+ / OS v1.5.1).

## Caracteristicas

### Design dos menus
O Design e as animações dos menus do jogo foram editados e adicionados com características semelhantes aos jogos da franquia Crash Bandicoot. Os menus são customizáveis com arquivos json.

![](https://github.com/Bioxcis/Crash-Bandicoot-Night-Funkin-Mod/blob/aad2dcdba91e0cf3523d9448a91b391f77406be4/art/CBNF_Menus.png)


## Novos Modos de Jogo
Está disponível 3 novos modos de jogo para o Modo Livre:

### Jogo Solo
Partidas de um jogador padrão.

### Modo Versus
Partidas de multijogadores onde ambos batalham pela vitória por pontuação ou até a morte.

### Estilo Dueto
Partidas de multijogadores onde ambos cantam juntos sem penalidades de morte.


## Novas configurações
Novas configurações disponíveis como: Novo Tamanho padrão da HUD do jogo, Habilitar movimentos de camera, Mostrar teclas configuradas das notas, Mostrar julgamento, etc.


## Criação de Notas em Músicas
Novas opções para criação de notas como:

### Movimentação da camera
Movimentos suaves ou intensos na camera quando o oponente/jogador acertar uma nota, sendo sua intensidade alterada em Lua.

### Drenagem de vida
Quando o oponente acertar uma nota a vida é drenada em uma determinada porcentagem, podendo matar ou não.

### Desativar Ghost Tapping
Desativa o Ghost Tapping para essa música e dificuldade específica.

### Desativar Ghost Tapping
Desativa o Ghost Tapping para essa música e dificuldade específica.

### Desativar Botões de Debug
Desativa os botões do Editor de Notas e Editor de Personagens para essa música e dificuldade específica.

### Trocar Linhas de lugar
Altera as linhas de notas dos personagens para caso você troque o Boyfriend de lugar com o Oponente.

### Habilitar trilhas
Habilita trilhas de sprites em cada um dos 3 personagens separadamente (Oponente, Girfriend e Boyfriend).

### Alterar Mania
Define a quantidade de notas/tipo de mania para sua música, que suporta de 1 a 18 teclas (o valor 4 notas padrão é 3).


## Novo Criador de Estágios
Crie seus estágios de forma mais simples e rápida!

* Utilize suas próprias imagens ou as disponíveis no jogo.
* Configure a posição dos elementos do cenário junto dos personagens padrão da música de forma livre.
* Ajuste o tamanho, rolagem, escala e alfa dos elementos do cenário.
* Copie determinadas informações de cada elemento ou exporte como um objeto (ver "setupStageSprite" em Lua).
* Altere as configurações do seu cenário e exporte para usa-lo na pasta `stages` do seu mod.


## Novas Notas Jogáveis
Novas notas criadas em dificuldades mais avançadas para as músicas padrão do jogo usando as novas configurações, sendo a principal o valor de Mania (5k, 6k, 7k, 8k e 9k).


## Conquistas
Leve Modificação no sistema de Conquistas e adição de novas Conquistas do Mod vistas no menu Missões.


## Funções Lua
Há diversas novas funções disponíveis em Lua para enriquecer mais as músicas.

Algumas delas são:

* Barras de Progresso
* Emissores de Partículas
* Personagens em Lua
* Novas Interpolações
* Criação de Flickers
* Criação de Trilhas de Rastro
* Iniciar Contagens Regressivas e muito mais!

Veja mais sobre as Funções Lua aqui na Wiki da Wumpa Engine!
