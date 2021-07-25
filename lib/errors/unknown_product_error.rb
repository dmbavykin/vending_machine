class UnknownProductError < ArgumentError
  def message
    I18n.t('unknown_product')
  end
end
