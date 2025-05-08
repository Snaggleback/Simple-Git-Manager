#!/bin/bash

# Função para exibir o status das alterações
show_status() {
    # Função para substituir os códigos de status por palavras personalizadas
    replace_status() {
        local status="$1"
        case "$status" in
            M) echo "Modificado" ;;
            ??|A) echo "Adicionado" ;;
            D) echo "Excluído" ;;
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
    while IFS= read -r line; do
        # Divide a linha em dois campos (status e caminho do arquivo)
        local status file
        read -r status file <<<"$line"

        local type named_status
        # Determina o tipo (arquivo ou diretório)
        type="Tipo: "
        [[ "${file}" == */ ]] && type+="diretório" || type+="arquivo"

        # Substitui o status usando a função replace_status
        named_status=$(replace_status "${status}")
        # Imprime o resultado
        echo "- ${file} (${type}) (${named_status})"

        # Armazena o caminho do arquivo e o status em um array passado pelo parâmetro da função
        eval "${1}+=(\"${file} (${type,,}, foi ${named_status,,}) \")"
    done <<<"$status_output" # Redireciona a saída para o loop while
}
