from PIL import Image

def image_to_c_header(image_path, output_header):
 
    img = Image.open(image_path).convert('L')
    img_gray = img.convert('L')
    img_gray.save("Resultado_gray.bmp")
    
    img = img.resize((512, 512)) 
    width, height = img.size
    
    pixels = list(img.getdata())
    
    with open(output_header, "w") as f:
        f.write(f"// Arquivo gerado automaticamente\n")
        f.write(f"#define IMG_WIDTH {width}\n")
        f.write(f"#define IMG_HEIGHT {height}\n\n")
        f.write("const unsigned char input_image[] = {\n")
        
        for i, p in enumerate(pixels):
            f.write(f"0x{p:02X}, ")
            if (i + 1) % 16 == 0:
                f.write("\n")
                
        f.write("\n};\n")
    print(f"Sucesso! Header {output_header} gerado com dimensões {width}x{height}")

if __name__ == "__main__":
    image_to_c_header("entrada.png", "image_data.h")
