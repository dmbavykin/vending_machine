class VendingMachine
  VALID_COINS = %w[5.0 3.0 1.0 0.5 0.25].freeze

  extend Forwardable

  attr_reader :products, :collected_coins

  def_delegators :transaction, :coins, :total, :change, :product

  def initialize
    init_transaction
    load_default_state
  end

  def put_coin(coin)
    coins << coin
    transaction.total += coin.to_f
  end

  def select_product(product_id)
    raise UnknownProductError unless products.key?(product_id)

    transaction.product = @products[product_id]
    raise OutOfStockError unless product['quantity'].positive?
  end

  def buy_product
    collect_coins
    if product['price'] < total
      change_amount = total - product['price']
      calculate_change(change_amount)
    end
    product['quantity'] -= 1
  end

  def init_transaction
    @transaction = OpenStruct.new(coins: [], total: 0, change: [], product: nil)
  end

  private

  attr_reader :transaction

  def calculate_change(change_amount)
    collected_coins.each do |(coin_amount, quantity)|
      break if change_amount.zero?
      next if coin_amount.to_f > change_amount || quantity.zero?

      needed_coins_quantity = (change_amount / coin_amount.to_f).floor
      available_coins_quantity = needed_coins_quantity > quantity ? quantity : needed_coins_quantity
      available_coins_quantity.times do
        change << coin_amount.to_f
        change_amount -= coin_amount.to_f
      end
    end
    take_coins_for_change(change_amount)
  end

  def take_coins_for_change(change_amount)
    return not_enough_change if change_amount.positive?

    change.each do |coin_amount|
      collected_coins[coin_amount.to_s] -= 1
    end
  end

  def not_enough_change
    coins.each do |coin|
      collected_coins[coin.to_s] -= 1
    end
    raise NotEnoughChangeError
  end

  def collect_coins
    coins.each do |coin|
      collected_coins[coin.to_s] += 1
    end
  end

  def load_default_state
    file_path = Dir.pwd + '/fixtures/default_state.json'
    data = JSON.parse(File.read(file_path))
    @products = data['products']
    @collected_coins = data['coins']
  end
end
