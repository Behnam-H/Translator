#!/home/behnam/translate/translate/bin/python

import sys
from googletrans import Translator
translator = Translator()
result = translator.translate(str(sys.argv[1]),dest='en')
print (result.text)