# KicadPDF Action

Generates a PDF for your Kicad schematics and PCB files.

## Inputs

### `input-files`

**Required** The Kicad files to process, separated by comma. Both schematic and PCB files can be mixed, with each being appended in the order of entry.

### `output-file`

**Required** The resulting PDF name and location.

### `copper-layers`

*PCB Only* The copper layers of the board, defaults to `F,B`.

### `pcb-layers`

*PCB Only* The layer types (e.g. "Adhesive", "Cu") to include in the export, in order of precedence, defaults to `Adhesive,Paste,Mask,Cu,Silkscreen`. Does not apply to inner layers, which always include just `Cu`. The order of layers is the order of entry, i.e. in the default configuration `Adhesive` would be the lowest, `Silkscreen` the highest.

### `extra-pcb-layers`

*PCB Only* Extra layers to show on their own sheet. `Edge.Cuts` is implicitly included.

## Example usage
```
uses: BenMMcLean/KicadPDF@1.0.1
with:
  input-files: schematic.kicad_sch
  output-file: schematic.pdf
```
