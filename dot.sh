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

# Função para importar funções
source_functions() {
    local script_dir="$1"
    local functions=("show-status" "press-close" "asker-yes-no" "asker" "replace-env" "initialize-git-repo")

    for func in "${functions[@]}"; do
        source "${script_dir}/functions/${func}.sh" || exit_with_error "Falha ao carregar '${func}.sh'"
    done
}

# Função para clonar o repositório
clone_repository() {
    local repository_git_path="$1"
    "${script_dir}/functions/clone-files.sh" "${repository_git_path}" || exit_with_error "Falha ao clonar o repositório"
}

# Função para obter e configurar o diretório do repositório
setup_repository_directory() {
    local script_dir repository_git_path
    # Obtendo o diretório do script
    script_dir=$(get_script_dir)

    # Obtendo o diretório do repositório
    repository_git_path=$(jq -r ".repository_path" <"${script_dir}/dotfiles.json") || exit_with_error "Falha ao obter o diretório do repositório do 'dotfiles.json'"

    # Substituindo o caminho $HOME pelo caminho absoluto
    repository_git_path=$(replace_env "${repository_git_path}")

    # Criando o diretório do repositório caso não exista
    mkdir -p "${repository_git_path}" || exit_with_error "Falha ao criar diretório '${repository_git_path}'"

    # Retornando o diretório do repositório
    echo "${repository_git_path}"
}

# Função principal
main() {
    local script_dir repository_git_path last_res dotfiles_modified commit_title commit_description

    # Obtendo o diretório do script
    script_dir=$(get_script_dir)

    # Carregando funções
    source_functions "${script_dir}"

    # Verifica se o primeiro argumento não é "--commit"
    if [ "$1" != "--commit" ]; then
        # Obtendo e configurando o diretório do repositório
        repository_git_path=$(setup_repository_directory)
        # Mudando para o diretório do repositório
        cd "${repository_git_path}" || exit_with_error "Falha ao acessar o diretório '${repository_git_path}'"
    fi

    if [ "$1" == "--commit" ]; then
        # Inicializando o repositório git apenas
        initialize_git_repo "$(pwd)"

    else
        # Inicializando o repositório git e clonando
        initialize_git_repo "${repository_git_path}"
        clone_repository "${repository_git_path}"
    fi

    dotfiles_modified=()
    show_status dotfiles_modified

    if [ "${#dotfiles_modified[@]}" -eq 0 ]; then
        press_close
        exit 0
    fi

    commit_title="Atualiza: Configurações atualizadas/melhoradas"
    commit_description="As configurações foram atualizadas para atender melhor às necessidades. Veja os arquivos de configuração em questão: ${dotfiles_modified[*]}"

    asker_yes_no "Deseja publicar essas alterações no GitHub?" "S" last_res

    if [ "$last_res" = true ]; then
        asker "Qual título você deseja adicionar? (tecle Enter para usar o título padrão):" commit_title
        asker "Qual descrição você deseja adicionar? (tecle Enter para usar a descrição padrão):" commit_description

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
main "$1"
