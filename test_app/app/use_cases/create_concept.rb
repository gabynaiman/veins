class CreateConcept < Veins::UseCase
  
  class Form < Veins::Form

    attr_reader :name
    attr_reader :language
    attr_reader :patterns

    private

    def validate(errors)
      errors[:name] << :blank if name.empty?
      errors[:language] << :blank if language.empty?
      errors[:language] << :invalid unless language.empty? || %w(EN ES PT).include?(language)
      errors[:patterns] << :empty if patterns.empty?
    end

  end

  private

  def run
    concept = Concept.new name: form.name, 
                          language: form.language, 
                          patterns: form.patterns

    repository[:concepts].save concept
  end

end