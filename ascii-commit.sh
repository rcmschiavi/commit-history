#!/bin/bash

pattern_file="pic.txt"

density_for_char() {
    case "$1" in
        " "|"0") echo 0 ;;
        "."|"1") echo 1 ;;
        ":"|"2") echo 3 ;;
        "*"|"3") echo 6 ;;
        "#"|"4") echo 10 ;;
        "@"|"5") echo 15 ;;
        *) echo 0 ;;
    esac
}

preview_for_char() {
    case "$1" in
        " "|"0") echo " " ;;
        "."|"1") echo "░" ;;
        ":"|"2") echo "▒" ;;
        "*"|"3") echo "▓" ;;
        "#"|"4") echo "█" ;;
        "@"|"5") echo "█" ;;
        *) echo " " ;;
    esac
}

if [ ! -d ".git" ]; then
    echo "Not a git repository"
    exit 1
fi

if [ ! -f "$pattern_file" ]; then
    echo "Pattern file not found"
    exit 1
fi

start_date=$(date -d "last sunday -51 weeks" +%Y-%m-%d)

mapfile -t lines < "$pattern_file"

echo "Rendering commit pattern:"
for line in "${lines[@]}"; do
    preview_line=""
    for col in {0..51}; do
        char="${line:$col:1}"
        preview_line+="$(preview_for_char "$char")"
    done
    echo "$preview_line"
done

echo "Commits will be applied now..."

for row in {0..6}; do
  for col in {0..51}; do
    char="${lines[$row]:$col:1}"
    commit_density=$(density_for_char "$char")
    if [ "$commit_density" -gt 0 ]; then
      commit_date=$(date -d "$start_date +$col weeks +$row days" +%Y-%m-%d)
      for i in $(seq 1 "$commit_density"); do
        echo "$commit_date - commit $i" > fake.txt
        git add fake.txt
        GIT_AUTHOR_DATE="$commit_date 12:00:00" \
        GIT_COMMITTER_DATE="$commit_date 12:00:00" \
        git commit -m "Fake commit on $commit_date"
      done
    fi
  done
done

rm -f fake.txt
echo "Done"