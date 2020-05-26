file = 'C:\Users\Z420\Desktop\exchange_folder\F-BOM.xml';
c = xml2struct(file);
I_asm = struct2I_Assembly(c);
asm = I_Assembly2Assembly(I_asm)