#find . -type f \( -name "*.java" -or -name "*.eol" -or -name "*.etl" -or -name "*.xtend" \) -exec sed -i '' -e $'s/	/    /g' {} +
find . -type f \( -name "*.java" -or -name "*.eol" -or -name "*.etl" -or -name "*.xtend" \) -exec sed -i '' -e "s/$(echo a | tr 'a' '\t')/    /g" {} +
find . -type f \( -name "*.java" -or -name "*.eol" -or -name "*.etl" -or -name "*.xtend" \) -exec sed -i '' -e "s/[$(echo a | tr 'a' '\t') ]*$//g" {} +
