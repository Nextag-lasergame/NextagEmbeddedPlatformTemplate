find . -regex '.*\.\(cpp\|hpp\|cc\|cxx\|h\)' -not -path "./third-party/*" -exec clang-format -style=file -i {} \;
