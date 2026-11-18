import pptx

prs = pptx.Presentation(r'c:\Users\hifzu\Downloads\T.ask\T.ask_Methodist_College_Final_Presentation.pptx')
for idx in [12, 15, 16, 17, 18, 19]:
    slide = prs.slides[idx]
    print(f'=== Slide {idx+1} ===')
    for s in slide.shapes:
        info = f'  shape={s.name}, type={s.shape_type}'
        if s.has_text_frame:
            info += f', text={s.text[:40]!r}'
        elif s.shape_type == pptx.enum.shapes.MSO_SHAPE_TYPE.PICTURE:
            info += f', pos=({s.left.inches:.2f}, {s.top.inches:.2f}), size=({s.width.inches:.2f}x{s.height.inches:.2f})'
        print(info)
