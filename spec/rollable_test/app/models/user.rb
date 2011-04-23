class User < ActiveRecord::Base
  include Rollable::Base
  rollables :pig, :horse,
    :roles => ['owner', 'rider', 'girlfriend'],
    :allow_nil => true
end
