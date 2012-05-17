class MasterData
  include Enumerable

  attr_reader :records
  
  def initialize()
    @records = []
    @records_by_key = {}
    @records_by_value = {}
  end

  def load_yaml(filepath=nil)
  
  end
  
  def master_data_item_class
    "MasterDataItem".constantize
  end
  
  # Adds master data
  # 
  # === Example
  # add_data :japanese, "ja"
  # add_data [:japanese, "ja"], [:chinese, "ch"], ...
  #
  def add_data(*args)
    if args[0].is_a? Array
      args.each { |x| add_master_item master_data_item_class.new(self, *x) }
    else
      add_master_item master_data_item_class.new(self, *args)
    end
  end
  
  # Adds master data
  # It will be hidden on form unless the record has the value.
  # It's used for obosolete values
  def add_hidden_data(*args)
    args[3] = {} if args.size<=3
    args[3][:hidden] = true
    add_data(*args)
  end
  
  def add_master_item(item)
    @records << item
    @records_by_key[item.key.to_sym] = item
    @records_by_value[item.value.to_s.to_sym] = item   
  end
  
  def each
    @records.each {|x| yield x}
  end
  
  def [](key_or_value)
    data(key_or_value)
  end
  
  def data(key_or_value)
    return nil if !key_or_value
    return nil if key_or_value.is_a?(String) && key_or_value.empty?

    return @records_by_key[key_or_value.to_sym] if @records_by_key.key? key_or_value.to_sym
    return @records_by_value[key_or_value.to_s.to_sym] if @records_by_value.key? key_or_value.to_s.to_sym
    
    raise MasterDataItemNotFoundError.new("#{key_or_value} is not found")
  end

  def data_by_value(value)
    @records_by_value[value.to_s.to_sym]
  end

  def data_by_key(key)
    @records_by_key[key.to_sym]
  end
  
  def raw_hash
    hash = {}
    @records.each{|r| hash[r.key.to_s] = r.value }
    hash
  end
  
  def form_data(current_value=nil)
    records = @records.select{|r| !r.hidden || r.to_s==current_value.to_s }
    records.map do |r|
      [r.label,r.value]
    end
  end

  # FIXME: refactor this and instance method so there is only one method
  def self.form_data_for(master_data, current_value=nil)
    records = master_data.select{|r| !r.hidden || r.to_s==current_value.to_s }
    records.map do |r|
      [r.label,r.value]
    end
  end
    
  def size
    @records ? @records.size : nil
  end

  def self.size
    self.instance.size
  end
    
  def self.[](key)
    self.instance[key]
  end  

  def self.method_missing(method, *args, &block)
    if self.instance[method]
      return self.instance[method]
    else
      super
    end
  end

  def method_missing(method, *args, &block)
    if @records_by_key[method.to_sym]
      return @records_by_key[method.to_sym]
    else
      super
    end
  end

end

# Raised when the value is not found in MasterDataItems
class MasterDataItemNotFoundError < Exception; end
