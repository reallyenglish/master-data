
class MasterDataItem
  include Comparable
  attr_accessor :key, :value, :order, :hidden
  
  #attr_reader :master

  def initialize(master, *args)
    @master, @order, options = master, master ? master.size : 0, {}
    
    @key = args[0].to_sym
    @value = args[1]
    @order = args[2] if args.size>2 && args[2]
    
    options = args[3] if args.size>3 && args[3]
    @hidden = options[:hidden] ? true : false
  end
    
  def is?(key_or_value)
    if key_or_value.class==MasterDataItem
      @key==key_or_value.key
    else
      key_or_value.to_sym==@key || key_or_value==@value
    end
  end

  def in?(*key_or_value_list)
    key_or_value_list.each { |x| return true if is?(x) }
    false
  end
  
  def label(options={})
    default = key.to_s.humanize
    options[:scope] = ['activerecord', 'attributes', @master.class.name.underscore]
    options[:default] = default
    I18n.t key, options   
  end
  
  def to_s
    value.to_s
  end
  
  def to_i
    to_s.to_i
  end
  
  def to_sym
    key
  end
  
  def to_yaml
    value.to_s
  end

  #def ==(other)
  #  other = @master[other] unless other.is_a?(MasterDataItem)
  #  return false unless other && other.master == @master
  #  @key == other.key && @value == other.value
  #end 

  def <=>(other)
    other = @master[other] unless other.is_a?(MasterDataItem)
    #raise ArgumentError, "comparison of of #{other.master.class} with #{@master.class} failed" unless other && other.master == @master 
    if other
      @order <=> other.order
    else
      1
    end
  end

  def between?(from,to)
    self >= from && self <= to
  end

  def any?(*items)
    items.each do |i|
      return true if self==i
    end
    false
  end
  
  def ===(other)
    self==other
  end
  
  def method_missing(method, *args, &block)
    if method.to_s =~ /.+\?/
      key = method.to_s.sub "?", ""
      if @master[key]
        return is?(key)
      end
    end
    super
  end
    
  def humanize
  
  end

#  class Jail < Safemode::Jail
#    allow :label, :is?
#  end
end
