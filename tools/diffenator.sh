#!/bin/bash
echo "This script will give you the rendering output diffs."
read -p 'Before file: ' before
read -p 'After file: ' after
read -p 'Output directory: ' output_dir
# read -p 'Threshold: ' thresh

after_filename=$(basename "$after")

full_path="$output_dir/${after_filename}_img"
echo "Output to: $full_path"

mkdir "$full_path"
touch "$full_path/$after_filename".html

diffenator "$before" "$after" --marks_thresh 10 --mkmks_thresh 10 --kerns_thresh 1 --glyphs_thresh 0.1 --metrics_thresh 1 -rd -r "$full_path" -html > "$full_path/$after_filename".html
# mv output.html $after.html