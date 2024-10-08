#!/bin/bash

#!/bin/bash

# Função para exibir mensagens de erro e sair
exit_with_error() {
    echo "Erro: ${1}" >&2
    exit 1
}

# Função para obter o diretório do script
get_script_dir() {
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    echo "${script_dir}"
}

# Função para importar functions
source_functions() {
    local script_dir="$1"
    source "${script_dir}/functions/show-status.sh" || exit_with_error "Falha ao carregar 'show-status.sh'"
    source "${script_dir}/functions/press-close.sh" || exit_with_error "Falha ao carregar 'press-close.sh'"
    source "${script_dir}/functions/asker-yes-no.sh" || exit_with_error "Falha ao carregar 'asker-yes-no.sh'"
    source "${script_dir}/functions/asker.sh" || exit_with_error "Falha ao carregar 'asker.sh'"
    source "${script_dir}/functions/replace-env.sh" || exit_with_error "Falha ao carregar 'replace-env.sh'"
}

# Função principal
main() {
    # Definindo variáveis locais que serão usadas dentro da função
    local script_dir last_res dotfiles_modified commit_title commit_description

    # Obtendo o diretório do script
    script_dir=$(get_script_dir)
    # Carregando functions
    source_functions "$script_dir"

    if [ ! -d ".git" ]; then
        # Caso o diretório não contenha um repositório Git
        asker_yes_no "O diretório informado não contém um repositório Git. Deseja criar um?" "S" last_res
        if [ "${last_res}" = true ]; then
            # Caso o usuário deseje criar um repositório Git
            git init || exit_with_error "Falha ao inicializar o repositório Git"      # Cria o repositório Git
            git branch -M main || exit_with_error "Falha ao definir o nome da branch" # Cria a branch chamada 'main'
            # Define o repositório remoto
            asker "Deseja adicionar remotamente o repositório github? (tecle enter para não):" last_res
            # Caso o usuário deseje adicionar remotamente o repositório github
            [ -n "${last_res}" ] && git remote add origin "${last_res}"
        else
            press_close
            exit 0
        fi
    else
        echo "O diretório informado contém um repositório Git"
    fi

    dotfiles_modified=()
    show_status dotfiles_modified

    if [ "${#dotfiles_modified[@]}" -eq 0 ]; then
        press_close
        exit 0
    fi

    commit_title="Atualiza: Atualização nos Arquivos e Estrutura"
    commit_description="Os arquivos foram atualizadas para atender melhor às necessidades. Veja o que foi feito nessa atualização: ${dotfiles_modified[*]}"

    asker_yes_no "Deseja publicar essas alterações no github?" "S" last_res

    if [ "$last_res" = true ]; then
        asker "Qual título você deseja adicionar? (tecle enter para usar o título padrão):" commit_title
        asker "Qual descrição você deseja adicionar? (tecle enter para usar a descrição padrão):" commit_description

        asker_yes_no "Confirma a publicação com o título \"${commit_title}\" e a descrição \"${commit_description:0:20}...\"?" "S" last_res

        if [ "$last_res" = true ]; then
            git add -A
            git commit -m "$commit_title" -m "$commit_description"
            git push
        fi
    fi

    press_close
}

# Chama a função principal
main

