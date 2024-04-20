#!/bin/bash

asker_yes_no() {
    # Resposta padrão definida
    local resposta_padrao="${2,,}"

    while true; do
        # Imprime a pergunta na tela e lê a resposta do usuário
        if [ "${resposta_padrao}" = "n" ]; then
            # Caso a resposta padrão seja não, o N fica maior
            printf "%s [s/N]: " "${1}"
        else
            # Caso a resposta padrão seja sim, o S fica maior
            printf "%s [S/n]: " "${1}"
        fi

        local resposta
        IFS= read -r resposta

        # Se a resposta estiver vazia, consideramos a resposta padrão para pergunta
        if [ -z "${resposta}" ]; then
            # Se a respota padrão for não, então retornamos 0
            if [ "${resposta_padrao}" = "n" ]; then
                eval "${3}=false"
                return 0
            fi
            # Se a resposta padrão for qualquer valor diferente, então retornamos 1
            eval "${3}=true"
            return 0
        fi

        # Inicia uma estrutura de seleção baseada na resposta
        case "${resposta}" in
        [SsYy])
            # Se a resposta for sim (s, S, y, Y)
            eval "${3}=true"
            return 0
            ;;
        [Nn])
            # Se a resposta for não (n, N)
            eval "${3}=false"
            return 0
            ;;
        *)
            # Se a resposta não for nem sim nem não
            # Imprime uma mensagem pedindo uma resposta válida
            printf "\rPor favor, responda com sim ou não. "
            ;;
        esac
    done
}
