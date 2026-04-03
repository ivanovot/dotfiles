#!/bin/bash
# Скрипт для установки dotfiles через stow с удалением конфликтов
sudo pacman -S --needed - < ~/explicit-packages.txt
curl -fsSL https://install.danklinux.com | sh

DOTFILES_DIR=~/dotfiles   # путь к твоему репозиторию dotfiles
TARGET_DIR=~              # домашняя директория, куда ставим симлинки

cd "$DOTFILES_DIR" || { echo "Репозиторий dotfiles не найден"; exit 1; }

# Проходим по каждой папке (пакету) в dotfiles
for pkg in */ ; do
    pkg_name="${pkg%/}"
    echo "Обрабатываем пакет: $pkg_name"

    # Находим все файлы/директории внутри пакета
    for file in "$pkg"* "$pkg".*; do
        base_file="${file#$pkg}"
        target_path="$TARGET_DIR/$base_file"

        # Если файл/директория или симлинк существует — удаляем
        if [ -e "$target_path" ] || [ -L "$target_path" ]; then
            echo "Удаляем конфликтующий файл/симлинк: $target_path"
            rm -rf "$target_path"
        fi
    done

    # Создаём симлинки через stow
    stow -v -t "$TARGET_DIR" "$pkg_name"
done

echo "Все пакеты dotfiles установлены через stow."
