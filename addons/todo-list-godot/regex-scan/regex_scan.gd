class_name RegexScan extends Node


#	Busca o padrão regex definido #TODO para orientar o desenvolvedor que há tarefas pendentes
#	- Warnings e na lista lateral (UI específica) 
# Como faz?
#	- Irá usar dados vindos do editor_scan (dependencia fraca) via signal (evento)
# Onde faz?
#	- No método MatchCaseTodo, procurando o case do regex #TODO em qualquer parte do códgo que anteceda um comentário,
# tudo o que estiver na frente até a próxima quebra de linha é o descritivo do TODO.

#Regex match: No inicio da linha, qualquer coisa entre # e TODO, incluindo espaços em branco e letras em qualquer quantidade.
var regex_pattern_todo = "^(#\\s*.[a-zA-Z]*TODO)" #Match #TODO montar o padrão de regex para pegar 'todos'
var regex : RegEx

func _init():
	regex = RegEx.new()
	regex.compile(regex_pattern_todo)

func MatchCaseTodo(path:String) -> Array[String]:
	if not FileAccess.file_exists(path):
		return [] #Retorna vazio?
	# Abrir o arquivo
	var script := FileAccess.open(path, FileAccess.READ) as FileAccess
	# Ler seu conteúdo
	var content := script.get_as_text()
	# Conta quant
	var max_line_quantities = content.get_slice_count("\n") # Não gera bug, pois o interpretador já aplica a quebra de linha na leitura do conteudo
	
	# Cria um Array de String por quebra de linha 
	var splited_lines := content.split("\n", true, max_line_quantities)
	
	var result : Array[String] = []
	for i:String in splited_lines:
		var item := regex.search(i)
		if item != null and not item.get_string() == null:
			result.append(i) #Se tem match, append a linha toda.
	return result
	pass
