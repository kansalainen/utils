#!/bin/bash

# Укажите ваш GitLab URL и токен доступа
GITLAB_URL="https://scm.x5.ru"
PRIVATE_TOKEN="***"
PROJECT_ID="***"  # Замените на ID вашего проекта

# Переменные для пагинации
page=1
per_page=100  # Максимальное количество элементов на странице

# Получаем список всех пайплайнов
while true; do
    pipelines=$(curl --silent --header "PRIVATE-TOKEN: $PRIVATE_TOKEN" "$GITLAB_URL/api/v4/projects/$PROJECT_ID/pipelines?page=$page&per_page=$per_page")

    # Проверяем, есть ли пайплайны
    if [ "$(echo "$pipelines" | jq 'length')" -eq 0 ]; then
        echo "Нет пайплайнов для удаления."
        break
    fi

    # Извлекаем ID всех пайплайнов
    pipeline_ids=$(echo "$pipelines" | jq -r '.[].id')

    # Удаляем каждый пайплайн
    for pipeline_id in $pipeline_ids; do
        echo "Удаляем пайплайн с ID: $pipeline_id"
        response=$(curl --silent --request DELETE --header "PRIVATE-TOKEN: $PRIVATE_TOKEN" "$GITLAB_URL/api/v4/projects/$PROJECT_ID/pipelines/$pipeline_id")

        # Проверяем ответ на успешное удаление
        if [ "$?" -eq 0 ]; then
            echo "Пайплайн с ID: $pipeline_id успешно удален."
        else
            echo "Ошибка при удалении пайплайна с ID: $pipeline_id."
        fi
    done

    # Переходим к следующей странице
    page=$((page + 1))
done

echo "Все пайплайны удалены."
