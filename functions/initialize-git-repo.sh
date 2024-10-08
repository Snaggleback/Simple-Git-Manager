#!/bin/bash

# Função para inicializar o repositório Git (se necessário)
initialize_git_repo() {
    local repository_git_path="$1"
    if [ ! -d "${repository_git_path}/.git" ]; then
        asker_yes_no "O diretório informado não contém um repositório Git. Deseja criar um?" "S" last_res
        if [ "${last_res}" = true ]; then
            git init || exit_with_error "Falha ao inicializar o repositório Git"
            git branch -M main || exit_with_error "Falha ao definir o nome da branch"
            asker "Deseja adicionar remotamente o repositório github? (tecle enter para não):" last_res
            [ -n "${last_res}" ] && git remote add origin "${last_res}"
        else
            press_close
            exit 0
        fi
    else
        echo "O diretório informado contém um repositório Git"
    fi
}