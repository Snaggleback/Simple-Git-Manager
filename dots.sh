#!/bin/bash

# Variável usada para armazenar as últimas respostas
last_res=""

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Importa as funções dos arquivos
source "${script_dir}/plugins/show-status.sh"
source "${script_dir}/plugins/press-close.sh"
source "${script_dir}/plugins/asker-yes-no.sh"
source "${script_dir}/plugins/asker.sh"

repository_git_path=$(jq -r ".repository_path" <"${script_dir}/config/config.json")

# Clona os arquivos para o diretório informado
"${script_dir}/plugins/clone-files.sh" "${repository_git_path}"

mkdir -p "${repository_git_path}"
cd "${repository_git_path}" || exit

# Verifica se o diretório contém o diretório .git
if [ -d ".git" ]; then
    echo "O diretório ${repository_git_path} contém um repositório Git"
else
    asker_yes_no "O diretório ${repository_git_path} não contém um repositório Git. Deseja criar um?" "S" last_res
    if [ "${last_res}" = true ]; then
        git init
        git branch -M main
        asker "Deseja adicionar remotamente o repositório github? (tecle enter para não):" last_res
        if [ -n "${last_res}" ]; then
            git remote add origin "${last_res}"
        fi
    else # Se não deseja criar, encerra o script
        exit 0
    fi
fi

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

# Se o usuário deseja publicar
if [ "${last_res}" = true ]; then
    asker "Qual título você deseja adicionar? (tecle enter para usar o título padrão):" commit_title
    asker "Qual descricão você deseja adicionar? (tecle enter para usar a descricão padrão):" commit_description

    asker_yes_no "Confirma a publicação com o título \"${commit_title}\" e a descricão \"${commit_description:0:20}...\"?" "S" last_res

    if [ "${last_res}" = true ]; then
        git add -A
        git commit -m "${commit_title}" -m "${commit_description}"
        git push
    fi
fi

press_close
