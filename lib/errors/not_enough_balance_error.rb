class NotEnoughBalanceError < ArgumentError
  def message
    I18n.t('not_enough_balance')
  end
end
