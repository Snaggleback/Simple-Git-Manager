#!/bin/bash

repository_path="${1}"

# Lista dos caminhos que estão sendo monitorados atualmente
monitored_path=(
    # Arquivos de configuração dentro de ".config"
    "$HOME/.config/dunst"
    "$HOME/.config/htop"
    "$HOME/.config/i3/config"
    "$HOME/.config/kitty"
    "$HOME/.config/picom"
    "$HOME/.config/ranger"
    "$HOME/.config/rofi"
    "$HOME/.config/user-dirs.dirs"
    "$HOME/.config/neofetch"
    "$HOME/.config/fontconfig"
    # Ícones svg/png do sistema personalizados
    "$HOME/.icons/system"
    # Scripts personalizados
    "$HOME/.scripts"
    # Aliases e personalizações do bash
    "$HOME/.bashrc"
    # Configurações do meu Visual Studio Code
    "$HOME/.config/Code/User/settings.json"
    "$HOME/.config/Code/User/keybindings.json"
)

# Copiando todos os arquivos para dentro da nossa pasta
for path in "${monitored_path[@]}"; do

    # Nome do caminho (sem contar o final) do diretório atual
    directory_name=$(dirname "${path}")

    # Lógica, se um caminho for igual à HOME do usuário, então significa que ele não é um diretório e sim um arquivo, ou seja, podemos simplesmente copia-lo
    if [ "${directory_name}" = "$HOME" ]; then

        # Copia então o caminho para o diretório atual
        cp -rp "${path}" "${repository_path}"

        # Pula para o próximo
        continue
    fi

    # Imprime a base do diretório, sem contar o final e sem contar o $HOME
    directory_base=$(echo "${directory_name}" | cut -d'/' -f4-)
    # Se caso for diretório dentro de diretório, ele irá criar logo os diretórios
    mkdir -p "${repository_path}/${directory_base}"

    # Copia efetivamente do caminho orginal pata o nosso diretório (agora sem preocupações :D)
    cp -rp "${path}" "${repository_path}/${directory_base}"
done
