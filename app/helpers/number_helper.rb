module NumberHelper

  def percentage_with_varying_accuracy(decimal)

    percentage = decimal * 100

    decimal_places = percentage < 0.01 ? 5 : 2

    percentage.round(decimal_places).to_s + "%"
  end

  # Same as pluralize helper but with the number formatted using
  # a delimiter.
  def pluralize_with_delimiter(count, singular, plural = nil)
    word = if (count == 1 || count =~ /^1(\.0+)?$/)
      singular
    else
      plural || singular.pluralize
    end

    "#{number_with_delimiter(count) || 0} #{word}"
  end

end