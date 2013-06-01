actions :install

attribute :bin_path, :kind_of => String, :name_attribute => true

def initialize(*args)
  super
  @action = :install
end
