import sys, glob
from PIL import Image
d, out = sys.argv[1], sys.argv[2]
step = int(sys.argv[3]) if len(sys.argv) > 3 else 1
fs = sorted(glob.glob(d + '/f*.png'))[::step][:48]
W = 6; H = (len(fs) + W - 1) // W
sheet = Image.new('RGB', (256 * W, 192 * H), 'white')
for i, f in enumerate(fs):
    sheet.paste(Image.open(f).convert('RGB'), ((i % W) * 256, (i // W) * 192))
sheet.save(out)
