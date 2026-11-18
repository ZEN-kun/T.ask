import pptx, os

path = r'c:\Users\hifzu\Downloads\T.ask\T.ask_Methodist_College_Final_Presentation.pptx'
prs = pptx.Presentation(path)
print(f'Total slides: {len(prs.slides)}')
size_kb = os.path.getsize(path) / 1024
print(f'File size: {size_kb:.2f} KB')

for idx, slide in enumerate(prs.slides):
    pictures = [s.name for s in slide.shapes if s.shape_type == pptx.enum.shapes.MSO_SHAPE_TYPE.PICTURE]
    tables = [s.name for s in slide.shapes if s.has_table]
    titles = [s.text.replace('\n', ' ')[:40] for s in slide.shapes if s.has_text_frame and ('Title' in s.name or 'TextBox 17' in s.name or idx == 0)]
    t_str = titles[0] if titles else 'No title'
    print(f'Slide {idx+1:02d}: Title="{t_str}" | Pics={pictures} | Tables={tables}')
