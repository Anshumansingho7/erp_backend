class Api::ProductsController < ApplicationController
  before_action :set_shop
  before_action :set_product, only: [ :show, :update, :destroy ]

  def index
    offset = params[:offset].present? ? params[:offset].to_i : 0
    limit  = params[:limit].present? ? params[:limit].to_i : 10

    total_products = @shop.products.order(created_at: :desc)
    products = total_products.offset(offset).limit(limit).includes(:master_product)

    render json: {
      products:  products.map { |product|
        product.as_json.merge(price: product.price)
      },
      total: total_products.count
    }, status: :ok
  end

  def show
    render json: @product.as_json.merge(price: @product.price), status: :ok
  end

  def create
    product = @shop.products.new(product_params)

    if product.save
      render json: { message: "Product created", product: product.as_json.merge(price: product.price) }, status: :created
    else
      render json: { errors: product.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @product.update(product_params)
      render json: { message: "Product updated", product: @product.as_json.merge(price: @product.price) }, status: :ok
    else
      render json: { errors: @product.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @product.destroy
    render json: { message: "Deleted successfully" }, status: :ok
  end

  private

  def set_shop
    @shop = current_user.company.shops.find(params[:shop_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Shop not found" }, status: :not_found
  end

  def set_product
    @product = @shop.products.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Product not found" }, status: :not_found
  end

  def product_params
    params.require(:product).permit(:master_product_id, :quantity, :discount)
  end

  def product_with_price(product)
    product.as_json.merge(price: product.price)
  end
end
