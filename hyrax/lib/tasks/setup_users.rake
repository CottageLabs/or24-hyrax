namespace :or2024 do
  desc 'Add users to OR2024. usage: or2024:setup_users["users.json", "false"]'
  task :setup_users, [:seedfile, :update_users] => :environment do |task, args|

    seedfile = args.seedfile
    update_user = args.update_users
    if update_user.is_a? String
      if update_user.downcase == 'false'
        update_user = false
      else
        update_user = true
      end
    end
    
    if (File.exist?(seedfile))
      puts("Running task to add / update users from seedfile: #{seedfile}")
    else
      abort("ERROR: missing seedfile for user setup: #{seedfile}")
    end

    seed = JSON.parse(File.read(seedfile))

    admin_role = Role.where(name: "admin").first_or_create!
    seed.fetch('users', []).each_with_index do |user, index|
      user_count = index + 1
      puts "--- User: #{user_count} ---"

      newuser = User.find_by(email: user["email"])

      unless newuser
        messages = "Creating user #{user["email"]}"

        newuser = User.new(
          email: user["email"],
          display_name: user["name"]
        )
        newuser.password = user["password"]
        newuser.save!
      else
        messages = "Updating user #{newuser.email}"
      end

      if user["role"] == "admin"
        unless admin_role.users.include?(newuser)
          admin_role.users << newuser
          admin_role.save!
        end
      end
      puts messages
    end

    # finished creating users
    ##############################################
  end

end

# Example json file
# {
#   "users":
#   [{
#     "email": "example_user@hyrax",
#     "password": "password",
#     "name": "Example User",
#     "saml_id": "urn:oasis:names:tc:SAML:attribute:pairwise-id",
#      "orcid": "orcid id",
#     "role": "crc_1280_group_manager",
#     group_id: "vd66vz88c"
#   }]
# }
