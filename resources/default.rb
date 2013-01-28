actions :install

attribute :version, :kind_of => String, :name_attribute => true

def initialize(*args)
  super
  @action = :install
end
