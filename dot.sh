#!/bin/bash

# Função para exibir mensagens de erro e sair
exit_with_error() {
    echo "Erro: $1" >&2
    exit 1
}

# Função para obter o diretório do script
get_script_dir() {
    # shellcheck disable=SC2005
    echo "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
}

# Função para importar funções
source_functions() {
    local script_dir="$1"
    local functions=("show-status" "press-close" "asker-yes-no" "asker" "replace-env" "initialize-git-repo")

    for func in "${functions[@]}"; do
        # shellcheck disable=SC1090
        source "${script_dir}/functions/${func}.sh" || exit_with_error "Erro ao carregar '${func}.sh'"
    done
}

# Função para clonar o repositório
clone_repository() {
    local repository_git_path="$1"
    "${script_dir}/functions/clone-files.sh" "$repository_git_path" || exit_with_error "Erro ao clonar o repositório"
}

# Função para configurar o diretório do repositório
setup_repository_directory() {
    local script_dir repository_git_path

    script_dir=$(get_script_dir)
    repository_git_path=$(jq -r ".repository_path" <"${script_dir}/dotfiles.json") || exit_with_error "Erro ao obter o diretório do repositório"
    repository_git_path=$(replace_env "$repository_git_path")

    mkdir -p "$repository_git_path" || exit_with_error "Erro ao criar diretório '$repository_git_path'"
    echo "$repository_git_path"
}

# Função principal
main() {
    local script_dir repository_git_path last_res dotfiles_modified commit_title commit_description

    script_dir=$(get_script_dir)
    source_functions "$script_dir"

    if [ "$1" != "--commit" ]; then
        repository_git_path=$(setup_repository_directory)
        cd "$repository_git_path" || exit_with_error "Erro ao acessar o diretório '$repository_git_path'"
    fi

    if [ "$1" == "--commit" ]; then
        initialize_git_repo "$(pwd)"
    else
        initialize_git_repo "$repository_git_path"
        clone_repository "$repository_git_path"
    fi

    dotfiles_modified=()
    show_status dotfiles_modified

    if [ "${#dotfiles_modified[@]}" -eq 0 ]; then
        press_close
        exit 0
    fi

    commit_title="Atualiza: Arquivos e Pastas atualizadas/melhoradas"
    commit_description="Os arquivos foram atualizadas para atender melhor às necessidades. Arquivos modificados: ${dotfiles_modified[*]}"

    asker_yes_no "Deseja salvar as alterações?" "S" last_res

    if [ "$last_res" = true ]; then
        asker "Título do commit (Enter para padrão):" commit_title
        asker "Descrição do commit (Enter para padrão):" commit_description

        git add -A
        git commit -m "$commit_title" -m "$commit_description"

        asker_yes_no "Confirmar publicação com título '${commit_title}' e descrição '${commit_description:0:20}...'?" "S" last_res

        if [ "$last_res" = true ]; then
            git push
        fi
    fi

    press_close
    echo ""
}

# Executa a função principal
main "$1"
