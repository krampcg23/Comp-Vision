from googletrans import Translator

if __name__ == "__main__":
   # translator = Translator()
   # translator.translate('apple pie is my favorite', dest='ja')

    translator = Translator()
    translation = translator.translate('apple pie is my favorite', dest='es')
    print(translation.origin, ' -> ', translation.text)

