class ValidationError < StandardError

  attr_reader :errors

  def initialize(errors)
    @errors = errors
    super "Validation errors in #{errors.keys.join(', ')}"
  end

end