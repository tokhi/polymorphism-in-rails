class Picture < ActiveRecord::Base
	 belongs_to :imageable, polymorphic: true
	 belongs_to :file_asset
	 after_create :build_asset_file

	 private
	 def build_asset_file
	 	self.build_file_asset(permission: "public", filename: name)
	 end
end
