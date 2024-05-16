.PHONY: build local deploy validate clean

# Compilação padrão
build:
	go mod tidy
	@echo "Iniciando a compilação com AWS SAM"
	sam build

# Inicia o SAM local
local: build
	@echo "Executando a aplicação localmente..."
	sam local start-api

# Comando SAM Deploy com variables de ambiente
deploy:
	@if [ -z "$(ENV)" ]; then \
		echo "Uso: make deploy ENV=<environment>"; \
		exit 1; \
	fi; \
	echo "Definindo arquivo de parâmetros com base no ambiente fornecido $(ENV)"; \
	PARAMS_FILE="env-$(ENV).json"; \
	if [ ! -f "$$PARAMS_FILE" ]; then \
		echo "Arquivo de parâmetros não encontrado: $$PARAMS_FILE"; \
		exit 1; \
	fi; \
	echo "Lendo e formatando os parâmetros para o formato correto"; \
	PARAMS=$$(jq -r 'to_entries|map("\(.key)=\(.value|tostring)")|.[]' $$PARAMS_FILE | xargs); \
	if [ -z "$$PARAMS" ]; then \
		echo "Erro: Os parâmetros estão vazios. Verifique o conteúdo de $$PARAMS_FILE ou instale a ferramenta jq"; \
		exit 1; \
	fi; \
	echo "Parâmetros convertidos: $$PARAMS"; \
	echo "Iniciando o deploy com AWS SAM"; \
	sam deploy --template-file template.yaml --stack-name propily-$(ENV) --capabilities CAPABILITY_IAM --parameter-overrides $$PARAMS

validate:
	@echo "Validando a aplicação"
	sam validate

clean:
	@echo "Limpando a aplicação"
	rm -rf .aws-sam
