class NotEnoughChangeError < ArgumentError
  def message
    I18n.t('not_enough_change')
  end
end
