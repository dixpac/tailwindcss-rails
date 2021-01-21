WEBPACK_STYLESHEETS_PATH = "#{Webpacker.config.source_path}/stylesheets"
APPLICATION_LAYOUT_PATH  = Rails.root.join("app/views/layouts/application.html.erb")

# Current webpacker version relies on an older version of PostCSS
# which the latest TailwindCSS version is not compatible with
#gsub_file("package.json", /\"@rails\/webpacker\".*/) { |matched_line| matched_line = LATEST_WEBPACKER }

say "Upgrade rails webpacker to latest"
run "yarn upgrade @rails/webpacker"

say "Setup CSS and SAAS with the latest @rails/webpacker"
run "yarn add css-loader mini-css-extract-plugin css-minimizer-webpack-plugin sass sass-loader"

say "Adding latest Tailwind CSS and postCSS"
run "yarn add postcss@latest postcss-loader postcss-import postcss-flexbugs-fixes postcss-preset-env"
run "yarn add tailwindcss@latest autoprefixer@latest"
insert_into_file "#{Webpacker.config.source_entry_path}/application.js", "\nrequire(\"stylesheets/application.scss\")\n"

say "Adding minimal configuration for Tailwind CSS to work properly"
directory Pathname.new(__dir__).join("stylesheets"), Webpacker.config.source_path.join("stylesheets")

insert_into_file "postcss.config.js", "require('tailwindcss'),\n\t", before: "  require('postcss-import')"

if APPLICATION_LAYOUT_PATH.exist?
  say "Add Tailwindcss include tags in application layout"
  insert_into_file Rails.root.join("app/views/layouts/application.html.erb").to_s, %(\n    <%= stylesheet_pack_tag "application", "data-turbo-track": "reload" %>), before: /\s*<\/head>/
else
  say "Default application.html.erb is missing!", :red
  say %(        Add <%= stylesheet_pack_tag "application", "data-turbo-track": "reload" %> within the <head> tag in your custom layout.)
end
