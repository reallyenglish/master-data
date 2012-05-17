module MasterData::ActiveRecordExtensions
  # it sets up master data
  def master_data(attribute, master=nil)
    attribute = attribute.to_sym
    attribute_s = attribute.to_s
    
    return if self.class.method_defined? "#{attribute_s}_master"

    if master.is_a? Class
      master_classname = master.name
    else
      master = attribute unless master
      master_classname = master.to_s.camelize
    end
                
    class_eval <<-EOT, __FILE__, __LINE__
      @@#{attribute_s}_master = #{master_classname}.instance
      
      def #{attribute_s}
        if @#{attribute_s} && self[:#{attribute_s}] == @#{attribute_s}.value
          @#{attribute_s}
        else
          value = self[:#{attribute_s}]
          @#{attribute_s} = @@#{attribute_s}_master[value] if value
          @#{attribute_s}
        end
      end
      
      def #{attribute_s}=(key_or_value)
        @#{attribute_s} = nil
        @#{attribute_s} = @@#{attribute_s}_master[key_or_value] if key_or_value
        if @#{attribute_s}
          self[:#{attribute_s}] = @#{attribute_s}.value
        else
          self[:#{attribute_s}] = nil
        end
      end
      
      def self.#{attribute_s}_master
        @@#{attribute_s}_master
      end
      def #{attribute_s}_master
        @@#{attribute_s}_master
      end
    EOT
    
  end 
end

ActiveRecord::Base.send(:extend, MasterData::ActiveRecordExtensions)
