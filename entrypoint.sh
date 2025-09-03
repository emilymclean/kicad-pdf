#!/bin/bash
set -e

# Check if the required arguments are provided
if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Usage: $0 <comma_separated_file_list> <output_pdf>"
  exit 1
fi

IFS=','

# Split the first argument (comma-separated file list) into an array
read -r -a file_array <<< "$(echo "$1" | tr -s '[:space:]' | sed 's/ *, */,/g')"

# Split the third argument (comma-separated copper layer list) into an array
read -r -a copper_layers <<< "$(echo "$3" | tr -s '[:space:]' | sed 's/ *, */,/g')"

# Split the fourth argument (comma-separated pcb layer list) into an array
read -r -a pcb_layers <<< "$(echo "$4" | tr -s '[:space:]' | sed 's/ *, */,/g')"

# Split the fifth argument (comma-separated extra pcb layer list) into an array
read -r -a extra_pcb_layers <<< "$(echo "$5" | tr -s '[:space:]' | sed 's/ *, */,/g')"

mkdir /home/kicad/tmp

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
    kicad-cli sch export pdf "$path" -o "/home/kicad/tmp/$index.pdf"
    output_pdfs+=("/home/kicad/tmp/$index.pdf")
  elif [ "$extension" == "kicad_pcb" ]; then
    combine_pdfs=()

    for j in "${!copper_layers[@]}"; do
      copper_layer="${copper_layers[$j]}"

      if [[ "$copper_layer" == "F" || "$copper_layer" == "B" ]]; then
        # This is a hack because Kicad won't let us order layers :/
        kicad-cli pcb export svg "$path" -o "/home/kicad/tmp/$j.svg" -l "Edge.Cuts"
        for k in "${!pcb_layers[@]}"; do
            pcb_layer="${pcb_layers[$k]}"
            kicad-cli pcb export svg "$path" -o "/home/kicad/tmp/$j.c.svg" -l "$copper_layer.$pcb_layer" --exclude-drawing-sheet
            python3 /scripts/combine.py "/home/kicad/tmp/$j.svg" "/home/kicad/tmp/$j.c.svg" "/home/kicad/tmp/$j.svg"
        done
        
        rsvg-convert -f pdf -o "/home/kicad/tmp/$index-$j.pdf" "/home/kicad/tmp/$j.svg"
      else
        kicad-cli pcb export svg "$path" -o "/home/kicad/tmp/$j.svg" -l "$copper_layer.Cu,Edge.Cuts"
        rsvg-convert -f pdf -o "/home/kicad/tmp/$index-$j.pdf" "/home/kicad/tmp/$j.svg"
      fi

      combine_pdfs+=("/home/kicad/tmp/$index-$j.pdf")
    done

    if [ ${#extra_pcb_layers[@]} -ne 0 ]; then
      kicad-cli pcb export svg "$path" -o "/home/kicad/tmp/x.svg" -l "${extra_pcb_layers[*]},Edge.Cuts"
      rsvg-convert -f pdf -o "/home/kicad/tmp/$index-x.pdf" "/home/kicad/tmp/x.svg"
      combine_pdfs+=("/home/kicad/tmp/$index-x.pdf")
    fi

    # Export PCB to PDF
    pdfunite "${combine_pdfs[@]}" "/home/kicad/tmp/$index.pdf"

    output_pdfs+=("/home/kicad/tmp/$index.pdf")
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
