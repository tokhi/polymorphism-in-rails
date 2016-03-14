## Polymorphic Associations in Rails 4

A slightly more advanced twist on associations is the polymorphic association. With polymorphic associations, a model can belong to more than one other model, on a single association. For example, you might have a picture model that belongs to either an employee model or a product model. Here's how this could be declared.

lets create the models:

```bash
rails g model Picture name
# we want to store details of the picture to the file_asset model:
rails g model file_asset path content_type permission filename
rails g model employee
rails g model product owner

```

make sure the picture migration file looks like this:

```ruby
class CreatePictures < ActiveRecord::Migration
  def change
    create_table :pictures do |t|
      t.string :name
      t.integer :file_asset_id
      t.references :imageable, polymorphic: true, index: true
      t.timestamps null: false
    end
  end
end

```
`t.references` will add `imageable_id` and `imageable_type` columns


```ruby
class Picture < ActiveRecord::Base
   belongs_to :imageable, polymorphic: true
   belongs_to :file_asset
   after_create :build_asset_file

   private
   def build_asset_file
    self.build_file_asset(permission: "public", filename: name)
   end
end
 

class FileAsset < ActiveRecord::Base
end


class Employee < ActiveRecord::Base
  has_many :pictures, as: :imageable
end
 
class Product < ActiveRecord::Base
  has_many :pictures, as: :imageable
end
```

lets login to console and cerate a product and then add a picture:

```bash
rails c
```

```ruby1.9.3-p545 :019 >   p=Product.new(owner: 'xyz')
 => #<Product id: nil, created_at: nil, updated_at: nil, owner: "xyz">
1.9.3-p545 :020 > p.pictures << Picture.create(name: "xyz.jpg")
   (0.1ms)  begin transaction
  SQL (1.5ms)  INSERT INTO "pictures" ("name", "created_at", "updated_at") VALUES (?, ?, ?)  [["name", "xyz.jpg"], ["created_at", "2016-03-14 11:44:17.900237"], ["updated_at", "2016-03-14 11:44:17.900237"]]
   (2.0ms)  commit transaction
 => #<ActiveRecord::Associations::CollectionProxy [#<Picture id: 6, name: "xyz.jpg", file_asset_id: nil, imageable_id: nil, imageable_type: nil, created_at: "2016-03-14 11:44:17", updated_at: "2016-03-14 11:44:17">]>
1.9.3-p545 :021 > p.save
   (0.1ms)  begin transaction
  SQL (0.3ms)  INSERT INTO "products" ("owner", "created_at", "updated_at") VALUES (?, ?, ?)  [["owner", "xyz"], ["created_at", "2016-03-14 11:44:23.326704"], ["updated_at", "2016-03-14 11:44:23.326704"]]
  SQL (0.1ms)  INSERT INTO "file_assets" ("permission", "filename", "created_at", "updated_at") VALUES (?, ?, ?, ?)  [["permission", "public"], ["filename", "xyz.jpg"], ["created_at", "2016-03-14 11:44:23.328449"], ["updated_at", "2016-03-14 11:44:23.328449"]]
  SQL (0.2ms)  UPDATE "pictures" SET "imageable_id" = ?, "imageable_type" = ?, "file_asset_id" = ?, "updated_at" = ? WHERE "pictures"."id" = ?  [["imageable_id", 1], ["imageable_type", "Product"], ["file_asset_id", 4], ["updated_at", "2016-03-14 11:44:23.329632"], ["id", 6]]
   (2.2ms)  commit transaction
 => true
```
Lets add another model:

 ```bash
 rails g model user email
 rake db:migrate
```

Modify the user model as below:

```ruby
class User < ActiveRecord::Base
  has_one :picture, as: :imageable
end

```
Lets play with the new model:

```ruby
 1.9.3-p545 :010 > u = User.new
 => #<User id: nil, email: nil, created_at: nil, updated_at: nil>
1.9.3-p545 :011 > u.email="fo@dfd.de"
 => "fo@dfd.de"
1.9.3-p545 :012 > u.create_picture(name: 'foo232')
   (0.1ms)  begin transaction
  SQL (0.4ms)  INSERT INTO "pictures" ("name", "imageable_type", "created_at", "updated_at") VALUES (?, ?, ?, ?)  [["name", "foo232"], ["imageable_type", "User"], ["created_at", "2016-03-14 11:41:08.124947"], ["updated_at", "2016-03-14 11:41:08.124947"]]
   (1.8ms)  commit transaction
 => #<Picture id: 5, name: "foo232", file_asset_id: nil, imageable_id: nil, imageable_type: "User", created_at: "2016-03-14 11:41:08", updated_at: "2016-03-14 11:41:08">
1.9.3-p545 :013 > u.save
   (0.1ms)  begin transaction
  SQL (1.5ms)  INSERT INTO "users" ("email", "created_at", "updated_at") VALUES (?, ?, ?)  [["email", "fo@dfd.de"], ["created_at", "2016-03-14 11:41:18.275582"], ["updated_at", "2016-03-14 11:41:18.275582"]]
  SQL (0.1ms)  INSERT INTO "file_assets" ("permission", "filename", "created_at", "updated_at") VALUES (?, ?, ?, ?)  [["permission", "public"], ["filename", "foo232"], ["created_at", "2016-03-14 11:41:18.278925"], ["updated_at", "2016-03-14 11:41:18.278925"]]
  SQL (0.1ms)  UPDATE "pictures" SET "imageable_id" = ?, "file_asset_id" = ?, "updated_at" = ? WHERE "pictures"."id" = ?  [["imageable_id", 2], ["file_asset_id", 3], ["updated_at", "2016-03-14 11:41:18.280748"], ["id", 5]]
   (15.4ms)  commit transaction
 => true

 ```
 This is the picture for the last user:

 ```ruby
 1.9.3-p545 :014 > User.last.picture
  User Load (0.3ms)  SELECT  "users".* FROM "users"  ORDER BY "users"."id" DESC LIMIT 1
  Picture Load (0.2ms)  SELECT  "pictures".* FROM "pictures" WHERE "pictures"."imageable_id" = ? AND "pictures"."imageable_type" = ? LIMIT 1  [["imageable_id", 2], ["imageable_type", "User"]]
 => #<Picture id: 5, name: "foo232", file_asset_id: 3, imageable_id: 2, imageable_type: "User", created_at: "2016-03-14 11:41:08", updated_at: "2016-03-14 11:41:18">
 ```
