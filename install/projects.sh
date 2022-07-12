urls=(
  AdventOfCode
  TheRustBook
  TheDockerBook
  crackingTheCodingInterview
  leetCode
)

mkdir -p ~/Projects
cd ~/Projects
for url in "${urls[@]}"; do
  if [ ! -d "$HOME/Projects/$url" ]; then
    git clone "https://github.com/jm96441n/$url.git"
  fi
done
cd ~

# set up notion enhancements
#sudo chmod -R a+wr /usr/local/lib/node_modules
#sudo chmod -R a+wr /usr/local/bin
#sudo chmod -R a+wr /Applications/Notion.app/Contents/Resources
#npm i -g notion-enhancer
