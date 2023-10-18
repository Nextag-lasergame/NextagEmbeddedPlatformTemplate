files_formatted=1

files=$(find . -type f \( -name \*.cpp -o -iname \*.h -o -iname \*.c -o -iname \*.cc -o -iname \*.hpp \) -not -path "*build*" -not -path "*third-party*")
files=$(echo "$files" | tr " " "\n")

for file in $files
do
  clang-format --dry-run --Werror "$file"
  if [ $? -ne 0 ]; then
    files_formatted=0
  fi
done

if [ $files_formatted -eq 0 ]; then
  exit 1
fi