require 'minitest_helper'

describe CreateConcept do

  def form(name, language, patterns)
    CreateConcept::Form.new name: name, 
                            language: language, 
                            patterns: patterns
  end

  it 'Successful' do
    concept = CreateConcept.run! form('word', 'EN', ['lit: word'])

    concept.must_be_instance_of Concept
    concept.id.must_equal 1
    concept.name.must_equal 'word'
    concept.language.must_equal 'EN'
    concept.patterns.must_equal ['lit: word']
    
    repository[:concepts].find(concept.id).must_equal concept
  end

  it 'Fail - Empty name' do
    proc { CreateConcept.run! form('', 'EN', ['lit: word']) }.must_raise_validation_error name: [:blank]
  end

  it 'Fail - Empty language' do
    proc { CreateConcept.run! form('word', '', ['lit: word']) }.must_raise_validation_error language: [:blank]
  end

  it 'Fail - Invalid language' do
    proc { CreateConcept.run! form('word', 'X', ['lit: word']) }.must_raise_validation_error language: [:invalid]
  end

  it 'Fail - Without patterns' do
    proc { CreateConcept.run! form('word', 'EN', []) }.must_raise_validation_error patterns: [:empty]
  end

end