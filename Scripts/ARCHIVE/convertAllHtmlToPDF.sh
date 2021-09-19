# https://wkhtmltopdf.org/index.html
# sudo apt install wkhtmltopdf
for filename in *.html; do
    [ -e "$filename" ] || continue
    NEW_FILE_NAME=$(basename "$filename" .html).pdf
    wkhtmltopdf --page-size Letter "$filename" "${NEW_FILE_NAME}"
done

