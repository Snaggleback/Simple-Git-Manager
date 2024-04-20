#!/bin/bash

# Variável usada para armazenar as últimas respostas
last_res=""

# Importa as funções dos arquivos
source plugins/show-status.sh
source plugins/press-close.sh
source plugins/asker-yes-no.sh
source plugins/asker.sh

# Cria um array vazio para armazenar os arquivos modificados
dotfiles_modified=()
# Mostra o status dos arquivos modificados e atribui os arquivos modificados ao array
show_status dotfiles_modified

if [ -z "${dotfiles_modified[*]}" ]; then
    press_close
    exit 0 # Se o array estiver vazio, não faz nada e encerra o script
fi

commit_title="Atualiza: Configurações atualizadas/melhoradas"
commit_description="As configurações foram atualizadas para atender melhor às minhas necessidades. Veja os arquivos de configuração em questão: ${dotfiles_modified[*]}"

asker_yes_no "Deseja publicar essas alterações no github?" "S" last_res

if [ "${last_res}" = true ]; then
    asker_yes_no "Deseja personalizar o título e a descricão do commit?" "N" last_res

    if [ "${last_res}" = true ]; then
        asker "Qual título você deseja adicionar?" commit_title
        asker "Qual descricão você deseja adicionar?" commit_description
    fi

    asker_yes_no "Confirma a publicação com o título \"${commit_title}\" e a descricão \"${commit_description:0:20}...\"?" "S" last_res

    if [ "${last_res}" = true ]; then
        git add -A
        git commit -m "${commit_title}" -m "${commit_description}"
    fi
fi
