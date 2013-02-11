require 'dummyproject/dummyproject'

# The toplevel namespace for dummyproject
#
# You should describe the basic idea about dummyproject here
require 'utilrb/logger'
module DummyProject
    extend Logger::Root('DummyProject', Logger::WARN)
end

