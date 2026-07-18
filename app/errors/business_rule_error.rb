class BusinessRuleError < StandardError
  attr_reader :details

  def initialize(message, details = nil)
    super(message)
    @details = details
  end
end