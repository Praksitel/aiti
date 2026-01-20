docker-compose down -v --remove-orphans
docker-compose up -d --build
echo "init.db"
docker-compose cp sql/initdb.sh aiti_db:/tmp/initdb.sh
docker-compose cp sql/users.sql aiti_db:/tmp/users.sql
docker-compose cp sql/db.sql aiti_db:/tmp/db.sql
docker-compose cp sql/create_tables.sql aiti_db:/tmp/create_tables.sql
docker-compose cp sql/fill_tables.sql aiti_db:/tmp/fill_tables.sql
docker-compose exec aiti_db chmod +x /tmp/initdb.sh
if docker-compose exec aiti_db /tmp/initdb.sh; then
  echo "БД инициализирована"
else
  echo "❌ Ошибка инициализации БД"
  docker-compose logs aiti_db
  exit 1
fi
echo "init.db done"
sleep 1
if curl -f http://localhost:8000/health > /dev/null 2>&1; then
    echo "Python сервис успешно запущен!"
    echo ""
    echo "=========================================="
    echo "Сервис работает!"
    echo "Адрес: http://localhost:8000"
    echo "Документация: http://localhost:8000/docs"
    echo "Проверка здоровья: http://localhost:8000/health"
    echo "=========================================="
    echo ""
    echo "Для просмотра логов: docker-compose logs -f order_service"
    echo "Для остановки: docker-compose down"
    echo "Для перезапуска: ./run.sh"
    echo ""

    # Показываем логи (работает пока не нажмем Ctrl+C)
    echo "Вывод логов (Ctrl+C для выхода):"
    docker-compose logs -f order_service
else
    echo "❌ Ошибка: Сервис не запустился"
    echo "Логи:"
    docker-compose logs order_service
    exit 1
fi
docker-compose down -v --remove-orphans