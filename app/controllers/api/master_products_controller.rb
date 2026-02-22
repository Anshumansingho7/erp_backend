class Api::MasterProductsController < ApplicationController
  before_action :set_master_product, only: [ :show, :update, :destroy ]

  def index
    offset = params[:offset].present? ? params[:offset].to_i : 0
    limit  = params[:limit].present? ? params[:limit].to_i : 10

    total_products = current_user.company.master_products.order(created_at: :desc)
    products = total_products.offset(offset).limit(limit)

    render json: {
      products: products,
      total: total_products.count
    }, status: :ok
  end

  def show
    render json: @master_product, status: :ok
  end

  def create
    product = current_user.company.master_products.new(master_product_params)

    if product.save
      render json: { message: "Product created", product: product }, status: :created
    else
      render json: { errors: product.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @master_product.update(master_product_params)
      render json: { message: "Product updated", product: @master_product }, status: :ok
    else
      render json: { errors: @master_product.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @master_product.destroy
    render json: { message: "Product deleted" }, status: :ok
  end

  private

  def set_master_product
    @master_product = current_user.company.master_products.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Product not found" }, status: :not_found
  end

  def master_product_params
    params.require(:master_product).permit(:name, :sku, :price, :description)
  end
end
