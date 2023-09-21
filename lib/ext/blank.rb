Object.class_eval do
  def blank?
    false
  end

  def present?
    !blank?
  end
end

NilClass.class_eval do
  def blank?
    true
  end
end

String.class_eval do
  def blank?
    gsub(/\s/, '').empty?
  end
end

Enumerable.module_eval do
  def blank?
    size == 0
  end
end
