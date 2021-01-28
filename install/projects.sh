urls=(
  https://github.com/jm96441n/AdventOfCode.git
  https://github.com/jm96441n/TheRustBook.git
  https://github.com/jm96441n/TheDockerBook.git
  https://github.com/jm96441n/crackingTheCodingInterview.git
  https://github.com/jm96441n/leetCode.git
)

mkdir -p ~/Projects
cd ~/Projects
for url in "${urls[@]}"
do
  git clone ${url}
done
cd ~

# set up notion enhancements
#sudo chmod -R a+wr /usr/local/lib/node_modules
#sudo chmod -R a+wr /usr/local/bin
#sudo chmod -R a+wr /Applications/Notion.app/Contents/Resources
#npm i -g notion-enhancer
