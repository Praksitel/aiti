#!/bin/bash
echo "=== Тестирование Order Service API ==="
echo ""

# Проверка здоровья
echo "1. Проверка здоровья:"
curl -s http://localhost:8000/health | python3 -m json.tool
echo ""

# Главная страница
echo "2. Главная страница:"
curl -s http://localhost:8000/ | python3 -m json.tool
echo ""

# Тестовый запрос
echo "3. Добавление товара в заказ 1:"
curl -s -X POST "http://localhost:8000/orders/add-item" \
  -H "Content-Type: application/json" \
  -d '{"order_id": 1, "product_id": 1, "quantity": 1}' | python3 -m json.tool
echo ""

# Проверка дублирования
echo "4. Добавление того же товара (должно увеличить количество):"
curl -s -X POST "http://localhost:8000/orders/add-item" \
  -H "Content-Type: application/json" \
  -d '{"order_id": 1, "product_id": 1, "quantity": 2}' | python3 -m json.tool
echo ""

# Ошибка недостатка товара
echo "5. Попытка заказа больше чем есть на складе:"
curl -s -X POST "http://localhost:8000/orders/add-item" \
  -H "Content-Type: application/json" \
  -d '{"order_id": 1, "product_id": 1, "quantity": 1000}' | python3 -m json.tool
echo ""

echo "Тестирование завершено!"