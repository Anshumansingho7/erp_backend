class Api::ShopsController < ApplicationController
  before_action :set_shop, only: [ :show, :update, :destroy ]

  def index
    offset = params[:offset].present? ? params[:offset].to_i : 0
    limit  = params[:limit].present? ? params[:limit].to_i : 10

    total_shops = current_user.company.shops.order(created_at: :desc)
    shops = total_shops.offset(offset).limit(limit)

    render json: {
      shops: shops,
      total: total_shops.count
    }, status: :ok
  end

  def show
    render json: @shop, status: :ok
  end

  def create
    shop = current_user.company.shops.new(shop_params)

    if shop.save
      render json: { message: "Shop created", shop: shop }, status: :created
    else
      render json: { errors: shop.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @shop.update(shop_params)
      render json: { message: "Shop updated", shop: @shop }, status: :ok
    else
      render json: { errors: @shop.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @shop.destroy
    render json: { message: "Shop deleted" }, status: :ok
  end

  private

  def set_shop
    @shop = current_user.company.shops.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Shop not found" }, status: :not_found
  end

  def shop_params
    params.require(:shop).permit(:name, :address, :phone)
  end
end
