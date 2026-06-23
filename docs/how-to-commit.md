# sobre
Vamos usar semantic commits + gitflow para estruturar deploy automático para o itch.io. Lembre-se que essa configuração é apenas para PLUGINS, ou seja, para games precisaria usar algo como 'cycjimmy/semantic-release-action'
.releaserc.json -> estrutura o semantic-release, dizendo quando deve ser gerado as tags de release, o formato e as regras. 
Uma regra é definida por 'type', que define se vira 'minor' ou 'patch', ou mesmo nada. É totalmente flexível.

# gitflow
- feature\* é onde se trabalha no dia a dia. Sai de develop e volta para develop por PR. Os commits devem ser feitos com formato convencional commits.
- develop, é a branch de integração, todas as features se encontram aqui primeiro. É onde o jogo toma 'forma' em seu estado mais recente, mas ainda não necessáriamente estável.
- release\x.y.z - quando a develop está num bom ponto para lançar, criamos a branch de release para fazer os ajustes finais:
	- polimento
	- correção de bugs pequenos
	- sem novas features
Testa-se tudo antes de subir para a produção.
- main, só recebe merge de release\* ou hotfix\*. Cada coisa que chega na main é, por definição, uma versão pronta para publicar.
	- push na main dispara o release.yml

- hotfix\*, sai direto da main, quando tem bugs urgente em produção, corrige, faz merge de volta na main. Isso gera tag/patch e também faz merge em develop para não perder a correção na próxima release.

# Commitando nesse projeto
- Use commits semânticos com as buzzwords abaixo

## buzzwords
- feature/*, usar:
	- feat:<description>
	- fix: <description>
	- doc: <description>
	- remove: <description>


## workflow
- commits em feature\* usando buzzwords
- PR para develop --> trigger --> pr-build.yml (validação)
- release\x.y.z criada quando tudo o que está na develop está pronto, testa e faz merge na 'main'.
- push na main --> trigger --> release.yml 
	- roda, lê os commits, decide a versão.
		- feat : MINOR
		- fix : patch
		- breaking change: major
	- cria a tag
- tag criada dispara deploy.yml e builda com essa versão.
