activate :livereload
activate :relative_assets
activate :directory_indexes

activate :deploy do |deploy|
  deploy.build_before = true
  deploy.method = :git
end
