# KicadPDF Action

Generates a PDF for specified Kicad files

## Inputs

### `input-files`

**Required** The Kicad files to process

### `output-file`

**Required** The name of the resulting CSV BOM

### `copper-layers`

The copper layers of the board, defaults to `F,B`

### `pcb-layers`

The layer types (e.g. "Adhesive", "Cu") to include in the export, in order of precedence, defaults to `Adhesive,Paste,Mask,Cu,Silkscreen`

## Example usage
```
uses: BenMMcLean/KicadPDF@v1
with:
  input-files: schematic.kicad_sch
  output-file: schematic.pdf
```
