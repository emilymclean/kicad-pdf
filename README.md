# KicadPDF Action

Generates a PDF for specified Kicad files

## Inputs

### `input-files`

**Required** The Kicad files to process

### `output-file`

**Required** The name of the resulting CSV BOM

## Example usage
```
uses: BenMMcLean/KicadPDF@v1
with:
  input-files: schematic.kicad_sch
  output-file: schematic.pdf
```
