#!/bin/bash

# Função (usa git) para mostrar as alterações
show_status() {
    # Função para substituir os códigos de status por palavras personalizadas
    replace_status() {
        local status
        status="$1"
        case "$status" in
        M) echo "Modificado" ;;
        \?\?) echo "Adicionado" ;;
        A) echo "Adicionado" ;;
        D) echo "Excluído" ;;
        # Se não corresponder a nenhum dos casos acima, apenas imprime o status original
        *) echo "$status" ;;
        esac
    }

    # Executa o comando git status -s e armazena a saída em uma variável local
    local status_output
    status_output=$(git status -s)

    if [ -z "$status_output" ]; then
        # Caso a saída seja vazia, indica que não há mudanças pendentes
        echo "Nenhuma mudança pendente"
        return 1
    fi

    printf "Arquivos de configuração atualizados, veja as modificações:\n\n"

    # Loop utilizando o comando read
    while read -r line; do
        # Divide a linha em dois campos (status e caminho do arquivo)
        local status
        status=$(echo "$line" | awk '{print $1}')
        local file
        file=$(echo "$line" | awk '{print $2}')

        # Cria uma variável local para armazenar o tipo
        local type
        type="Tipo: "

        # Substitui o status usando a função replace_status
        local named_status
        named_status=$(replace_status "${status}")

        # Verifica se o caminho do arquivo termina em uma barra
        if [[ "${file}" == */ ]]; then
            type+="diretório"
        else # Se não termina em uma barra, é um arquivo
            type+="arquivo"
        fi

        # Substitui o status usando a função replace_status e imprime o resultado
        echo "- ${file} (${type})" "(${named_status})"
        # Armazena o caminho do arquivo e o status em um array passado pelo parâmetro da função
        eval "${1}+=(\"${file} (${type,,}, foi ${named_status,,}), \")"
    done <<<"$status_output" # Redireciona a saída para o loop while
}
