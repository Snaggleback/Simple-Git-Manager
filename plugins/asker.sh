#!/bin/bash

asker() {
    while true; do
        # Variável usada para armazenar a resposta
        local resposta
        # Imprime a resposta na tela e lê a pergunta e atribui à variável
        printf "%s " "${1}"
        IFS= read -r resposta

        # Verifica se a resposta está em branco ou se contêm apenas espaços
        if [ -z "${resposta}" ] || [[ ! "$resposta" =~ [^[:space:]] ]]; then
            # Informa o erro ao usuário
            # printf "\rPor favor, digite algo! "
            break
        else
            # Atribuindo diretamente o valor à variável utilizando o eval
            eval "${2}='${resposta}'"
            # Saí do loop
            break
        fi
    done
}
