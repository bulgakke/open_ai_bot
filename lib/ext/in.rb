Object.class_eval do
  def in?(collection)
    collection.include?(self)
  end
end
