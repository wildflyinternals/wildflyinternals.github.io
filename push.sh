JEKYLL_ENV=production jekyll build
git add assets CNAME _config.yml Gemfile _includes index.md _layouts _posts README.md _site push.sh feed.xml
git commit -a -m '.'
git push origin master

