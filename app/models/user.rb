class User < ActiveRecord::Base
	has_one :picture, as: :imageable
end
