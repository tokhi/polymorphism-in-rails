## Polymorphic Associations in Rails 4

A slightly more advanced twist on associations is the polymorphic association. With polymorphic associations, a model can belong to more than one other model, on a single association. For example, you might have a picture model that belongs to either an employee model or a product model. Here's how this could be declared.

lets create the models:

```bash
rails g model Picture name
rails g model employee
rails g model product owner

```

make sure the picture migration file looks like this:

```ruby
class CreatePictures < ActiveRecord::Migration
  def change
    create_table :pictures do |t|
      t.string :name
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

```ruby
p=Product.new(owner: 'xyz')

p.pictures << Picture.create(name: "xyz.jpg")
   (0.1ms)  begin transaction
  SQL (0.4ms)  INSERT INTO "pictures" ("name", "created_at", "updated_at") VALUES (?, ?, ?)  [["name", "xyz.jpg"], ["created_at", "2016-03-11 17:13:03.038722"], ["updated_at", "2016-03-11 17:13:03.038722"]]
   (1.5ms)  commit transaction
 => #<ActiveRecord::Associations::CollectionProxy [#<Picture id: 4, name: "xyz.jpg", imageable_id: nil, imageable_type: nil, created_at: "2016-03-11 17:13:03", updated_at: "2016-03-11 17:13:03">]>
1.9.3-p545 :013 > p.save
   (0.1ms)  begin transaction
  SQL (0.4ms)  INSERT INTO "products" ("owner", "created_at", "updated_at") VALUES (?, ?, ?)  [["owner", "xyz"], ["created_at", "2016-03-11 17:13:15.913142"], ["updated_at", "2016-03-11 17:13:15.913142"]]
  SQL (0.4ms)  UPDATE "pictures" SET "imageable_id" = ?, "imageable_type" = ?, "updated_at" = ? WHERE "pictures"."id" = ?  [["imageable_id", 3], ["imageable_type", "Product"], ["updated_at", "2016-03-11 17:13:15.915011"], ["id", 4]]
   (1.4ms)  commit transaction
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
1.9.3-p545 :001 > u = User.new
 => #<User id: nil, email: nil, created_at: nil, updated_at: nil>
1.9.3-p545 :002 > u.email="test@example.com"
 => "test@example.com"
.create_picture(name: "profPic.jpg")
   (0.1ms)  begin transaction
  SQL (0.5ms)  INSERT INTO "pictures" ("name", "imageable_type", "created_at", "updated_at") VALUES (?, ?, ?, ?)  [["name", "profPic.jpg"], ["imageable_type", "User"], ["created_at", "2016-03-11 17:02:37.609911"], ["updated_at", "2016-03-11 17:02:37.609911"]]
   (1.7ms)  commit transaction
 => #<Picture id: 3, name: "profPic.jpg", imageable_id: nil, imageable_type: "User", created_at: "2016-03-11 17:02:37", updated_at: "2016-03-11 17:02:37">
1.9.3-p545 :007 > u.save
   (0.1ms)  begin transaction
  SQL (0.4ms)  INSERT INTO "users" ("email", "created_at", "updated_at") VALUES (?, ?, ?)  [["email", "test@example.com"], ["created_at", "2016-03-11 17:02:43.113101"], ["updated_at", "2016-03-11 17:02:43.113101"]]
  SQL (0.3ms)  UPDATE "pictures" SET "imageable_id" = ?, "updated_at" = ? WHERE "pictures"."id" = ?  [["imageable_id", 1], ["updated_at", "2016-03-11 17:02:43.115287"], ["id", 3]]
   (1.8ms)  commit transaction
 => true
 ```
 This is the picture for the last user:

 ```ruby
 User.last.picture
  User Load (0.3ms)  SELECT  "users".* FROM "users"  ORDER BY "users"."id" DESC LIMIT 1
  Picture Load (0.2ms)  SELECT  "pictures".* FROM "pictures" WHERE "pictures"."imageable_id" = ? AND "pictures"."imageable_type" = ? LIMIT 1  [["imageable_id", 1], ["imageable_type", "User"]]
 => #<Picture id: 3, name: "profPic.jpg", imageable_id: 1, imageable_type: "User", created_at: "2016-03-11 17:02:37", updated_at: "2016-03-11 17:02:43">
 ```
