activate :livereload
activate :relative_assets
activate :directory_indexes

set :sass, :style => :expanded, :line_comments => false

activate :deploy do |deploy|
  deploy.build_before = true
  deploy.method = :git
end
