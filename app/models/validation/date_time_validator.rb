class DateTimeValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if !validate_datetime(value)
      record.errors[attribute] << "invalid date" 
    end
  end
  
  def validate_datetime(t)
    t.respond_to?(:sec) || DateTime.parse(t) rescue false
  end
end
