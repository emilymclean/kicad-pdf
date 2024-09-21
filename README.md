# KicadPDF Action

Generates a CSV BOM for a specified schematic

## Inputs

### `input-file`

**Required** The schematic to process

### `output-file`

**Required** The name of the resulting CSV BOM

## Example usage
```
uses: BenMMcLean/KicadPDF@v1
with:
  input-file: schematic.kicad_sch
  output-file: schematic.csv
```
