import argparse
import xml.etree.ElementTree as ET

def composite_svgs(svg1_path, svg2_path, output_path):
    # Parse the first SVG
    tree1 = ET.parse(svg1_path)
    root1 = tree1.getroot()

    # Parse the second SVG
    tree2 = ET.parse(svg2_path)
    root2 = tree2.getroot()

    for elem in root2:
        # Append the adjusted element to the first SVG
        root1.append(elem)

    # Write the composite SVG to the output file
    tree1.write(output_path)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Composite two SVG files.')
    parser.add_argument('svg1', help='Path to the first SVG file')
    parser.add_argument('svg2', help='Path to the second SVG file')
    parser.add_argument('output', help='Path to the output composite SVG file')

    args = parser.parse_args()
    composite_svgs(args.svg1, args.svg2, args.output)