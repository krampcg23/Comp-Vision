from googletrans import Translator

if __name__ == "__main__":
    f = open("temp/filteredText.txt", "r")
    translator = Translator()
    translation = translator.translate(f.read(), dest='es')
    f = open("temp/translated.txt", "w")
    f.write(translation.text)
    #print(translation.origin, ' -> ', translation.text)

