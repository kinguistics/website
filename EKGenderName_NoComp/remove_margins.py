import PIL, glob

EXTENSIONS = ['gif','jpeg','jpg','png']

def getAllWidthFactors(fileNames):
    widthFactors = []
    
    for fname in fileNames:
        try: img = PIL.Image.open(fname)
        except: 
            print "cannot open %s" % fname
            continue
        
        widthFactors.append(getWidthFactor(img))
    
    return widthFactors

def getWidthFactor(img):
    width, height = img.size
    widthFactor = float(width)/height
    
    return widthFactor

if __name__=='__main__':
    fileNames = []
    for ext in EXTENSIONS:
        fileNames.extend(glob.glob('*.%s' % ext))
    
    widthFactors = getAllWidthFactors(fileNames)