module Trimmer
  def self.append_features( base )
    base.before_validation do |model|
      model.attribute_names.each do |n|
        model[n] = model[n].strip if model[n].respond_to?( 'strip' )
      end
    end
  end
end