class Console
  EXIT_KEYWORD = 'exit'.freeze

  attr_reader :machine

  def initialize
    @machine = VendingMachine.new
  end

  def start
    loop { select_product }
  end

  private

  def select_product
    product_id = ask('choose') { product_list }
    machine.select_product(product_id)
    start_collecting_coins
  rescue UnknownProductError, OutOfStockError => e
    puts e.message
    select_product
  end

  def product_list
    machine.products.each do |product_id, product|
      puts "#{product_id}. #{product['name']} | $#{product['price']} | #{product['quantity']}"
    end
  end

  def start_collecting_coins
    while machine.total < machine.product['price']
      coin_amount = ask('put_coin', coins: machine.class::VALID_COINS)
      if machine.class::VALID_COINS.include?(coin_amount)
        machine.put_coin(coin_amount)
      else
        output('invalid_coin')
      end
      output('your_balance', balance: machine.total)
    end
    buy_product
  end

  def buy_product
    machine.buy_product
    output('product_is_bought', product: machine.product['name'])
    output('your_change', change: machine.change) if machine.change.any?
  rescue NotEnoughChangeError => e
    puts e.message
    output('take_your_money_back', refund: machine.coins)
  ensure
    machine.init_transaction
  end

  def output(message, **options)
    puts I18n.t(message, **options)
  end

  def ask(question, **options, &block)
    output(question, options) if question
    block.call if block_given?
    answer = gets.chomp
    answer.eql?(EXIT_KEYWORD) ? exit : answer
  end

  def exit
    output('see_you')
    Kernel.exit
  end
end
