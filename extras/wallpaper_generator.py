#!/usr/bin/env python3
"""
MilkOutside Wallpaper Generator - System Package Only Version
Uses only Python standard library and system image tools

Usage 1: python3 wallpaper_generator.py [gradient|solid] [width] [height]
Usage 2: python3 wallpaper_generator.py directory [path/to/png/folder] [width] [height]
Usage 3: python3 wallpaper_generator.py directory-replace [path/to/png/folder] [width] [height] [hex_color]
"""

import sys
import os
import subprocess

# MilkOutside color palette
COLORS = {
    'bg': '#000000',
    'bg_dark': '#000000', 
    'bg_highlight': '#040607',
    'bg_visual': '#394b70',
    'red1': '#e45555',
    'red': '#fda1a0',
    'blue': '#63c3dd',
    'blue1': '#4fd1e0',
    'magenta': '#e79cfb',
    'purple': '#9d7cd8',
    'cyan': '#7dcfff',
    'green': '#92cf9c',
    'yellow': '#f8e063',
    'orange': '#ffad00',
    'comment': '#595959',
    'fg': '#e8e8e8'
}

def find_system_tool():
    """Find available image manipulation tool"""
    tools = [
        ('convert', 'ImageMagick'),
        ('magick', 'ImageMagick'),
        ('ffmpeg', 'FFmpeg'),
        ('gm', 'GraphicsMagick')
    ]
    
    for tool, name in tools:
        if subprocess.run(['which', tool], capture_output=True).returncode == 0:
            print(f"Found {name} - using {tool}")
            return tool, name
    
    print("No suitable image tool found. Please install one of:")
    for tool, name in tools:
        print(f"  - {name} ({tool})")
    return None, None

def create_gradient_with_imagemagick(width, height, color1, color2, output_path, direction='diagonal'):
    """Create gradient using ImageMagick"""
    tool, name = find_system_tool()
    if not tool:
        return False
    
    try:
        if tool in ['convert', 'magick']:
            # Create gradient with ImageMagick
            if direction == 'diagonal':
                gradient_cmd = [
                    tool, '-size', f'{width}x{height}',
                    '-define', 'gradient:direction=northeast',
                    f'gradient:{color1}-{color2}',
                    output_path
                ]
            else:
                gradient_cmd = [
                    tool, '-size', f'{width}x{height}',
                    f'gradient:{color1}-{color2}',
                    output_path
                ]
        elif tool == 'ffmpeg':
            # FFmpeg gradient
            gradient_cmd = [
                'ffmpeg', '-y',
                '-f', 'lavfi',
                f'color=gradient={color1}:{color2}:size={width}x{height}',
                '-frames', '1',
                output_path
            ]
        elif tool == 'gm':
            # GraphicsMagick gradient
            gradient_cmd = [
                tool, 'convert', '-size', f'{width}x{height}',
                f'gradient:{color1}-{color2}',
                output_path
            ]
        else:
            return False
        
        result = subprocess.run(gradient_cmd, capture_output=True, text=True)
        if result.returncode == 0:
            return True
        else:
            print(f"Error creating gradient: {result.stderr}")
            return False
    except Exception as e:
        print(f"Error: {e}")
        return False

def generate_color_variations(base_color):
    """Generate minimal variations of a hex color to catch hue changes"""
    # Remove # if present
    color = base_color.lstrip('#')
    
    # Convert to RGB
    try:
        r = int(color[0:2], 16)
        g = int(color[2:4], 16)
        b = int(color[4:6], 16)
    except ValueError:
        return [base_color]
    
    variations = [base_color]
    
    # Generate only a few targeted variations for common small changes
    # Focus on the most likely variations for background colors
    variations.extend([
        f"#{r:02x}{g:02x}{b+1:02x}",  # B+1 (like 282c33 -> 282c34)
        f"#{r:02x}{g:02x}{b-1:02x}",  # B-1
        f"#{r:02x}{g+1:02x}{b:02x}",  # G+1
        f"#{r:02x}{g-1:02x}{b:02x}",  # G-1
        f"#{r+1:02x}{g:02x}{b:02x}",  # R+1
        f"#{r-1:02x}{g:02x}{b:02x}",  # R-1
    ])
    
    return variations

def resize_with_imagemagick(input_path, output_path, width, height, apply_theme=True, replace_background=False, replacement_color=None):
    """Resize image maintaining aspect ratio using ImageMagick"""
    tool, name = find_system_tool()
    if not tool:
        return False
    
    try:
        # First resize the image
        if tool in ['convert', 'magick']:
            resize_cmd = [
                tool, input_path,
                '-resize', f'{width}x{height}^',
                '-gravity', 'center',
                '-extent', f'{width}x{height}',
                'temp_resized.png'
            ]
        elif tool == 'ffmpeg':
            resize_cmd = [
                'ffmpeg', '-y', '-i', input_path,
                '-vf', f'scale={width}:{height}:force_original_aspect_ratio=decrease,crop={width}:{height}',
                '-frames', '1',
                'temp_resized.png'
            ]
        elif tool == 'gm':
            resize_cmd = [
                tool, 'convert', input_path,
                '-resize', f'{width}x{height}^',
                '-gravity', 'center',
                '-extent', f'{width}x{height}',
                'temp_resized.png'
            ]
        else:
            return False
        
        result = subprocess.run(resize_cmd, capture_output=True, text=True)
        if result.returncode != 0:
            print(f"Error resizing: {result.stderr}")
            return False
        
        # Apply processing based on mode
        if replace_background and replacement_color:
            # Replace target color and all its variations with black using a single command
            target_color = f"#{replacement_color}" if not replacement_color.startswith('#') else replacement_color
            color_variations = generate_color_variations(target_color)
            
            print(f"  Replacing {len(color_variations)} color variations based on {target_color}")
            
            # Use traditional sequential replacement approach but with fewer variations
            current_input = 'temp_resized.png'
            
            for i, color in enumerate(color_variations):
                temp_output = output_path if i == len(color_variations) - 1 else f"temp_var_{i}.png"
                
                cmd = [
                    tool, current_input,
                    '-fill', '#000000',
                    '-opaque', color,
                    temp_output
                ]
                
                result = subprocess.run(cmd, capture_output=True, text=True)
                if result.returncode == 0 and i < len(color_variations) - 1:
                    current_input = temp_output
                
        elif replace_background:
            # Replace near-black backgrounds with pure black
            blend_cmd = [
                tool, 'temp_resized.png',
                '-fill', '#000000',
                '-opaque', '#000000',
                '-fuzz', '35%',
                output_path
            ]
            
            result = subprocess.run(blend_cmd, capture_output=True, text=True)
            if result.returncode != 0:
                print(f"Error processing: {result.stderr}")
                subprocess.run(['rm', '-f', 'temp_resized.png'], capture_output=True)
                return False
                
        elif apply_theme:
            # Apply theme overlay
            blend_cmd = [
                tool, 'temp_resized.png',
                '-fill', COLORS['bg'],
                '-colorize', '25%',
                output_path
            ]
            
            result = subprocess.run(blend_cmd, capture_output=True, text=True)
            if result.returncode != 0:
                print(f"Error processing: {result.stderr}")
                subprocess.run(['rm', '-f', 'temp_resized.png'], capture_output=True)
                return False
        else:
            # No processing needed, just copy
            subprocess.run(['cp', 'temp_resized.png', output_path], capture_output=True)
            subprocess.run(['rm', '-f', 'temp_resized.png'], capture_output=True)
            return True
        
        # Cleanup temp files
        subprocess.run(['rm', '-f', 'temp_resized.png'], capture_output=True)
        if replacement_color:
            for i in range(len(color_variations)):
                subprocess.run(['rm', '-f', f'temp_var_{i}.png'], capture_output=True)
        
        return True
            
    except Exception as e:
        print(f"Error: {e}")
        subprocess.run(['rm', '-f', 'temp_resized.png'], capture_output=True)
        return False
    
    try:
        # First resize the image
        if tool in ['convert', 'magick']:
            resize_cmd = [
                tool, input_path,
                '-resize', f'{width}x{height}^',
                '-gravity', 'center',
                '-extent', f'{width}x{height}',
                'temp_resized.png'
            ]
        elif tool == 'ffmpeg':
            resize_cmd = [
                'ffmpeg', '-y', '-i', input_path,
                '-vf', f'scale={width}:{height}:force_original_aspect_ratio=decrease,crop={width}:{height}',
                '-frames', '1',
                'temp_resized.png'
            ]
        elif tool == 'gm':
            resize_cmd = [
                tool, 'convert', input_path,
                '-resize', f'{width}x{height}^',
                '-gravity', 'center',
                '-extent', f'{width}x{height}',
                'temp_resized.png'
            ]
        else:
            return False
        
        result = subprocess.run(resize_cmd, capture_output=True, text=True)
        if result.returncode != 0:
            print(f"Error resizing: {result.stderr}")
            return False
        
        # Apply processing based on mode
        if replace_background and replacement_color:
            # Replace target color and all its variations with black
            target_color = f"#{replacement_color}" if not replacement_color.startswith('#') else replacement_color
            color_variations = generate_color_variations(target_color)
            
            print(f"  Replacing {len(color_variations)} color variations based on {target_color}")
            
            current_input = 'temp_resized.png'
            
            # Apply replacements for each variation
            for i, color in enumerate(color_variations):
                temp_output = f"temp_replaced_{i}.png" if i < len(color_variations) - 1 else output_path
                
                blend_cmd = [
                    tool, current_input,
                    '-fill', '#000000',
                    '-opaque', color,
                    temp_output
                ]
                
                result = subprocess.run(blend_cmd, capture_output=True, text=True)
                if result.returncode != 0:
                    print(f"  Warning: Could not replace {color} (may not exist in image)")
                
                # Update current input for next iteration (use the last successful output)
                if i == 0:
                    current_input = output_path if len(color_variations) == 1 else 'temp_replaced_0.png'
                elif i < len(color_variations) - 1:
                    current_input = temp_output
                
        elif replace_background:
            # Replace near-black backgrounds with pure black
            blend_cmd = [
                tool, 'temp_resized.png',
                '-fill', '#000000',
                '-opaque', '#000000',
                '-fuzz', '35%',
                output_path
            ]
            
            result = subprocess.run(blend_cmd, capture_output=True, text=True)
            if result.returncode != 0:
                print(f"Error processing: {result.stderr}")
                subprocess.run(['rm', '-f', 'temp_resized.png'], capture_output=True)
                return False
                
        elif apply_theme:
            # Apply theme overlay
            blend_cmd = [
                tool, 'temp_resized.png',
                '-fill', COLORS['bg'],
                '-colorize', '25%',
                output_path
            ]
            
            result = subprocess.run(blend_cmd, capture_output=True, text=True)
            if result.returncode != 0:
                print(f"Error processing: {result.stderr}")
                subprocess.run(['rm', '-f', 'temp_resized.png'], capture_output=True)
                return False
        else:
            # No processing needed, just copy
            subprocess.run(['cp', 'temp_resized.png', output_path], capture_output=True)
            subprocess.run(['rm', '-f', 'temp_resized.png'], capture_output=True)
            return True
        
        # Cleanup temp files
        subprocess.run(['rm', '-f', 'temp_resized.png'], capture_output=True)
        if replacement_color:
            # Clean up temp files from color variations
            for i in range(20):  # Clean up to 20 temp files safely
                subprocess.run(['rm', '-f', f'temp_replaced_{i}.png'], capture_output=True)
        
        return True
            
    except Exception as e:
        print(f"Error: {e}")
        subprocess.run(['rm', '-f', 'temp_resized.png'], capture_output=True)
        return False

def process_png_directory(input_dir, width, height, apply_theme=True, replace_background=False):
    """Process PNG directory with optional theme application"""
    if not os.path.exists(input_dir):
        print(f"Error: Directory {input_dir} does not exist")
        return
    
    mode = "themed" if apply_theme else "clean"
    output_dir = f"milkoutside_{mode}_{width}x{height}"
    os.makedirs(output_dir, exist_ok=True)
    
    print(f"Processing directory: {input_dir}")
    print(f"Output: {output_dir}")
    print(f"Mode: {mode}")
    
    # Find all PNG files
    png_files = []
    for root, dirs, files in os.walk(input_dir):
        for file in files:
            if file.lower().endswith('.png'):
                png_files.append(os.path.join(root, file))
    
    print(f"Found {len(png_files)} PNG files to process...")
    
    processed_count = 0
    for i, png_path in enumerate(png_files):
        print(f"Processing {i+1}/{len(png_files)}: {os.path.basename(png_path)}")
        
        # Create output filename
        original_name = os.path.splitext(os.path.basename(png_path))[0]
        final_output = os.path.join(output_dir, f"milkoutside_{original_name}_{width}x{height}.png")
        
        try:
            if resize_with_imagemagick(png_path, final_output, width, height, apply_theme, replace_background):
                print(f"  -> {final_output}")
                processed_count += 1
            
        except Exception as e:
            print(f"  Error: {e}")
    
    print(f"Successfully processed {processed_count}/{len(png_files)} wallpapers")
    print(f"All wallpapers saved to: {output_dir}")

def process_png_directory_with_replacement(input_dir, width, height, replacement_color):
    """Process PNG directory and replace specific color with black"""
    if not os.path.exists(input_dir):
        print(f"Error: Directory {input_dir} does not exist")
        return
    
    output_dir = f"milkoutside_replaced_{replacement_color}_{width}x{height}"
    os.makedirs(output_dir, exist_ok=True)
    
    print(f"Processing directory: {input_dir}")
    print(f"Output: {output_dir}")
    print(f"Replacing color #{replacement_color} and slight variations with #000000")
    
    # Find all PNG files
    png_files = []
    for root, dirs, files in os.walk(input_dir):
        for file in files:
            if file.lower().endswith('.png'):
                png_files.append(os.path.join(root, file))
    
    print(f"Found {len(png_files)} PNG files to process...")
    
    processed_count = 0
    for i, png_path in enumerate(png_files):
        print(f"Processing {i+1}/{len(png_files)}: {os.path.basename(png_path)}")
        
        # Create output filename
        original_name = os.path.splitext(os.path.basename(png_path))[0]
        final_output = os.path.join(output_dir, f"milkoutside_{original_name}_{width}x{height}.png")
        
        try:
            # Replace specific color with black
            if resize_with_imagemagick(png_path, final_output, width, height, apply_theme=False, replace_background=True, replacement_color=replacement_color):
                print(f"  -> {final_output}")
                processed_count += 1
            else:
                print(f"  Failed to process {os.path.basename(png_path)}")
            
        except Exception as e:
            print(f"  Error: {e}")
    
    print(f"Successfully processed {processed_count}/{len(png_files)} wallpapers")
    print(f"All wallpapers saved to: {output_dir}")

def create_solid_wallpaper(width, height, output_path):
    """Create solid BLACK wallpaper"""
    tool, name = find_system_tool()
    if not tool:
        return False
    
    try:
        if tool in ['convert', 'magick']:
            cmd = [tool, '-size', f'{width}x{height}', f'xc:#000000', output_path]
        elif tool == 'ffmpeg':
            cmd = [
                'ffmpeg', '-y',
                '-f', 'lavfi',
                f'color=black:size={width}x{height}',
                '-frames', '1',
                output_path
            ]
        elif tool == 'gm':
            cmd = [tool, 'convert', '-size', f'{width}x{height}', f'xc:#000000', output_path]
        else:
            return False
        
        result = subprocess.run(cmd, capture_output=True, text=True)
        return result.returncode == 0
    except Exception as e:
        print(f"Error creating solid wallpaper: {e}")
        return False

def main():
    if len(sys.argv) < 2:
        print("Usage options:")
        print("1. Create from scratch:")
        print("   python3 wallpaper_generator.py [gradient|solid] [width] [height]")
        print("\n2. Process PNG directory:")
        print("   python3 wallpaper_generator.py directory [path/to/png/folder] [width] [height]")
        print("\n3. Process PNG directory (clean):")
        print("   python3 wallpaper_generator.py directory-clean [path/to/png/folder] [width] [height]")
        print("\n4. Process PNG directory with color replacement:")
        print("   python3 wallpaper_generator.py directory-replace [path/to/png/folder] [width] [height] [color]")
        print("\n5. Check system tools:")
        print("   python3 wallpaper_generator.py check")
        print("\nExamples:")
        print("   python3 wallpaper_generator.py solid 1920 1080")
        print("   python3 wallpaper_generator.py gradient 1920 1080")
        print("   python3 wallpaper_generator.py directory ./my_wallpapers 1920 1080")
        print("   python3 wallpaper_generator.py directory-clean ./my_wallpapers 1920 1080")
        print("   python3 wallpaper_generator.py directory-replace ./my_wallpapers 1920 1080 282c33")
        print("   python3 wallpaper_generator.py directory-replace ./my_wallpapers 1920 1080 1d202f")
        print("\nNote: Requires ImageMagick, GraphicsMagick, or FFmpeg")
        print("      - No logo/watermark added")
        print("      - Uses correct black background (#000000)")
        print("      - Replace specific colors with black")
        sys.exit(1)
    
    command = sys.argv[1].lower()
    
    if command == 'check':
        tool, name = find_system_tool()
        if tool:
            print(f"✅ {name} is available as '{tool}'")
        else:
            print("❌ No suitable image tool found")
            print("Install one of:")
            print("  Ubuntu/Debian: sudo apt install imagemagick")
            print("  Fedora: sudo dnf install ImageMagick")
            print("  macOS: brew install imagemagick")
            print("  Arch: sudo pacman -S imagemagick")
    
    elif command == 'directory':
        if len(sys.argv) < 3:
            print("Please specify a directory path")
            sys.exit(1)
        
        input_dir = sys.argv[2]
        width = int(sys.argv[3]) if len(sys.argv) > 3 else 1920
        height = int(sys.argv[4]) if len(sys.argv) > 4 else 1080
        
        process_png_directory(input_dir, width, height, apply_theme=True)
    
    elif command == 'directory-clean':
        if len(sys.argv) < 3:
            print("Please specify a directory path")
            sys.exit(1)
        
        input_dir = sys.argv[2]
        width = int(sys.argv[3]) if len(sys.argv) > 3 else 1920
        height = int(sys.argv[4]) if len(sys.argv) > 4 else 1080
        
        process_png_directory(input_dir, width, height, apply_theme=False, replace_background=True)
    
    elif command == 'directory-replace':
        if len(sys.argv) < 6:
            print("Please specify: directory path width height color")
            print("Example: python3 wallpaper_generator.py directory-replace ./wallpapers 1920 1080 282c33")
            sys.exit(1)
        
        input_dir = sys.argv[2]
        width = int(sys.argv[3])
        height = int(sys.argv[4])
        replacement_color = sys.argv[5]
        
        process_png_directory_with_replacement(input_dir, width, height, replacement_color)
    
    elif command in ['gradient', 'solid']:
        width = int(sys.argv[2]) if len(sys.argv) > 2 else 1920
        height = int(sys.argv[3]) if len(sys.argv) > 3 else 1080
        output_path = f"milkoutside_{command}_{width}x{height}.png"
        
        print(f"Creating {command} wallpaper at {width}x{height}...")
        
        if command == 'solid':
            if create_solid_wallpaper(width, height, output_path):
                print(f"Wallpaper saved as: {output_path}")
        
        elif command == 'gradient':
            if create_gradient_with_imagemagick(width, height, COLORS['bg'], COLORS['bg_highlight'], 
                                             output_path, 'diagonal'):
                print(f"Wallpaper saved as: {output_path}")
    
    else:
        print(f"Unknown command: {command}")
        sys.exit(1)

if __name__ == "__main__":
    main()