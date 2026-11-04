module DigestHelper
  def ordinal_date(time)
    String.new.tap do |formatted|
      date = time.to_date
      formatted << "#{date.day.ordinalize} of #{date.strftime("%B")}"
      formatted << " #{date.year}" unless this_year?(date)
    end
  end

  private

  def this_year?(date)
    date.year == Date.current.year
  end
end
