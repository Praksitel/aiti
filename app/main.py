from fastapi import FastAPI, HTTPException, Depends, status
from sqlalchemy import create_engine, Column, Integer, String, DateTime, ForeignKey
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, Session, relationship
from pydantic import BaseModel, validator
from typing import Optional
from datetime import datetime
import os

DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://postgres:password@localhost:5433/your_database")
engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

class Product(Base):
    __tablename__ = "products"
    id = Column(Integer, primary_key=True, index=True)
    amount = Column(Integer, nullable=False)
    price = Column(Integer, nullable=False)
    name = Column(String, nullable=False)

class Order(Base):
    __tablename__ = "orders"
    id = Column(Integer, primary_key=True, index=True)
    client_id = Column(Integer, nullable=False)
    dt = Column(DateTime, default=datetime.utcnow)

class OrderItem(Base):
    __tablename__ = "order_items"
    id = Column(Integer, primary_key=True, index=True)
    order_id = Column(Integer, ForeignKey("orders.id"), nullable=False)
    item = Column(Integer, ForeignKey("products.id"), nullable=False)
    count = Column(Integer, nullable=False, default=1)

class AddItemRequest(BaseModel):
    order_id: int
    product_id: int
    quantity: int

    @validator('quantity')
    def validate_quantity(cls, v):
        if v <= 0:
            raise ValueError('Количество должно быть положительным')
        return v

class AddItemResponse(BaseModel):
    success: bool
    message: str
    order_id: int
    product_id: int
    quantity: int
    total_quantity: Optional[int] = None
    stock_available: int

# Инициализация FastAPI
app = FastAPI(title="Order Service API")

# Dependency для получения сессии БД
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@app.post("/orders/add-item", response_model=AddItemResponse)
def add_item_to_order(request: AddItemRequest, db: Session = Depends(get_db)):
    order = db.query(Order).filter(Order.id == request.order_id).first()
    if not order:
        raise HTTPException(status_code=404, detail=f"Заказ {request.order_id} не найден")

    product = db.query(Product).filter(Product.id == request.product_id).first()
    if not product:
        raise HTTPException(status_code=404, detail=f"Товар {request.product_id} не найден")

    if product.amount < request.quantity:
        raise HTTPException(
            status_code=400,
            detail=f"Недостаточно товара. Доступно: {product.amount}"
        )

    try:
        existing_item = db.query(OrderItem).filter(
            OrderItem.order_id == request.order_id,
            OrderItem.item == request.product_id
        ).first()

        if existing_item:
            existing_item.count += request.quantity
            total_quantity = existing_item.count
            message = "Количество товара обновлено"
        else:
            new_item = OrderItem(
                order_id=request.order_id,
                item=request.product_id,
                count=request.quantity
            )
            db.add(new_item)
            total_quantity = request.quantity
            message = "Товар добавлен в заказ"

        product.amount -= request.quantity

        db.commit()

        return AddItemResponse(
            success=True,
            message=message,
            order_id=request.order_id,
            product_id=request.product_id,
            quantity=request.quantity,
            total_quantity=total_quantity,
            stock_available=product.amount
        )

    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Ошибка: {str(e)}")

@app.get("/health")
def health_check():
    return {"status": "ok", "timestamp": datetime.utcnow()}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)