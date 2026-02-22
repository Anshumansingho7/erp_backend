module Api
  class OrdersController < ApplicationController
    before_action :set_shop
    before_action :set_order, only: [ :show, :update, :destroy ]

    def index
      offset = params[:offset].present? ? params[:offset].to_i : 0
      limit  = params[:limit].present? ? params[:limit].to_i : 10

      total_orders = @shop.orders.order(created_at: :desc)
      orders = total_orders.offset(offset).limit(limit)

      render json: {
        orders: orders.as_json(include: :order_items),
        total: total_orders.count
      }, status: :ok
    end

    def show
      render json: @order.as_json(include: :order_items), status: :ok
    end

    def create
      order = @shop.orders.new(order_params)

      if order.save
        render json: { message: "Order created", order: order.as_json(include: :order_items) }, status: :created
      else
        render json: { errors: order.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def update
      if @order.update(order_params)
        render json: { message: "Order updated", order: @order.as_json(include: :order_items) }, status: :ok
      else
        render json: { errors: @order.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def destroy
      @order.destroy
      render json: { message: "Order deleted" }, status: :ok
    end

    private

    def set_shop
      @shop = current_user.company.shops.find(params[:shop_id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Shop not found" }, status: :not_found
    end

    def set_order
      @order = @shop.orders.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Order not found" }, status: :not_found
    end

    def order_params
      params.require(:order).permit(
        :customer_name,
        :customer_phone,
        order_items_attributes: [
          :product_id,
          :quantity,
          :discount
        ]
      )
    end
  end
end
