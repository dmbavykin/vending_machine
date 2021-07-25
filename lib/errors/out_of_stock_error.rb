class OutOfStockError < ArgumentError
  def message
    I18n.t('out_of_stock')
  end
end
