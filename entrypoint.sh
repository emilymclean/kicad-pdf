#!/bin/bash

# Check if the required arguments are provided
if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Usage: $0 <comma_separated_file_list> <output_pdf>"
  exit 1
fi

# Split the first argument (comma-separated file list) into an array
IFS=',' read -r -a file_array <<< "$1"

# Split the third argument (comma-separated file list) into an array
IFS=',' read -r -a board_layers <<< "${3:-F,B}"

mkdir /tmp

# Prepare an array to hold the output PDF files
output_pdfs=()

# Iterate through each file in the array
for i in "${!file_array[@]}"; do
  file="${file_array[$i]}"
  path="$file"
  index=$((i + 1)) # PDF output index starts at 1

  # Check the file extension
  extension="${file##*.}"

  if [[ "$extension" == "kicad_sch" || "$extension" == "sch" ]]; then
    # Export schematic to PDF
    kicad-cli sch export pdf "$path" -o "/tmp/$index.pdf"
    output_pdfs+=("/tmp/$index.pdf")
  elif [ "$extension" == "kicad_pcb" ]; then
    combine_pdfs=()

    for j in "${!board_layers[@]}"; do
      board_layer="${board_layers[$j]}"

      if [[ "$board_layer" == "F" || "$board_layer" == "B" ]]; then
        # This is a hack because Kicad won't let us order layers :/
        kicad-cli pcb export svg "$path" -o "/tmp/$j-Cu.svg" -l "$board_layer.Cu"
        kicad-cli pcb export svg "$path" -o "/tmp/$j-O.svg" -l "$board_layer.Adhesive,$board_layer.Paste,$board_layer.Mask,Edge.Cuts"
        kicad-cli pcb export svg "$path" -o "/tmp/$j-S.svg" -l "$board_layer.Silkscreen"

        python3 /scripts/combine.py "/tmp/$j-Cu.svg" "/tmp/$j-O.svg" "/tmp/$j.svg"
        python3 /scripts/combine.py "/tmp/$j.svg" "/tmp/$j-S.svg" "/tmp/$j.svg"

        rsvg-convert -f pdf -o "/tmp/$index-$j.pdf" "/tmp/$j.svg"
      else
        kicad-cli pcb export pdf "$path" -o "/tmp/$index-$j.pdf" -l "$board_layer.Cu" --ibt
      fi

      combine_pdfs+=("/tmp/$index-$j.pdf")
    done

    # Export PCB to PDF
    pdfunite "${combine_pdfs[@]}" "/tmp/$index.pdf"

    output_pdfs+=("/tmp/$index.pdf")
  else
    echo "Unsupported file type: $extension"
  fi
done

# Combine the output PDFs into a single PDF using pdfunite
if [ ${#output_pdfs[@]} -gt 0 ]; then
  echo "${output_pdfs[@]}"
  pdfunite "${output_pdfs[@]}" "/github/workspace/$2"
  echo "Combined PDF created at /github/workspace/$2"
else
  echo "No valid files to combine."
fi
