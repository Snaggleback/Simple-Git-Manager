#!/bin/bash

# Carregando o plugin de substituição de variáveis
source "${BASH_SOURCE[0]%/*}/replace-env.sh"

# Caminho do repositório que será enviado os arquivos clonados
repository_path="${1}"

# Caminho do arquivo de configuração
config_file="$(dirname "${BASH_SOURCE[0]}")/../dotfiles.json"

# Lista dos caminhos que estão sendo monitorados atualmente
monitored_paths=()

# Lê o arquivo JSON e adiciona cada elemento ao array
while IFS= read -r line; do
    # Substitui as variáveis de ambiente
    monitored_paths+=("$(replace_env "${line}")")
done < <(jq -r '.monitored_paths[]' "${config_file}")

# Copiando todos os arquivos para dentro da nossa pasta
for path in "${monitored_paths[@]}"; do
    # Nome do caminho (sem contar o final) do diretório atual
    directory_name=$(dirname "${path}")

    # Se o diretório atual for o $HOME ele copia e pula para o proximo
    if [ "${directory_name}" = "$HOME" ]; then
        # Copia então o caminho para o diretório atual
        cp -rp "${path}" "${repository_path}"
        continue
    fi

    # Imprime a base do diretório, sem contar o final e sem contar o $HOME
    directory_base=$(echo "${directory_name}" | cut -d'/' -f4-)
    # Se caso for diretório dentro de diretório, ele irá criar logo os diretórios
    mkdir -p "${repository_path}/${directory_base}"

    # Copia efetivamente do caminho orginal pata o nosso diretório (agora sem preocupações :D)
    cp -rp "${path}" "${repository_path}/${directory_base}"
done
