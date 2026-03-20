#!/bin/bash

# autolayout.sh - Automatically change i3 layout based on window count
# Usage: Place in i3 config: exec_always --no-startup-id /path/to/autolayout.sh

# Проверяем, установлен ли jq
if ! command -v jq &> /dev/null; then
    echo "Error: jq is not installed. Please install it: sudo apt install jq"
    exit 1
fi

# Функция для применения layout
apply_layout() {
    # Получаем количество окон в текущем workspace
    windows=$(i3-msg -t get_tree | jq '[recurse(.nodes[]) | select(.type=="workspace" and .focused==true) | .nodes[].nodes[].window] | length')
    
    # Применяем layout в зависимости от количества окон
    if [ "$windows" -eq 1 ]; then
        i3-msg layout splith > /dev/null
    elif [ "$windows" -eq 2 ]; then
        i3-msg layout tabbed > /dev/null
    elif [ "$windows" -ge 3 ]; then
        i3-msg layout stacked > /dev/null
    fi
}

# Основной цикл: слушаем события i3
echo "i3-autolayout started. Watching for window events..."

# Используем i3-msg -t subscribe для прослушивания событий
i3-msg -t subscribe -m '[ "window" ]' | while read -r event; do
    # При любом событии окна применяем layout
    apply_layout
done
