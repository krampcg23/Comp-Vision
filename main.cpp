#include <string>
#include <tesseract/baseapi.h>
#include <leptonica/allheaders.h>
#include <opencv2/opencv.hpp>
#include <map>
#include <fstream>
#include <algorithm> 
using namespace std;
using namespace cv;

void filterAndAdd(string word, map<string, int> dictionary, string &filteredText) {
    transform(word.begin(), word.end(), word.begin(), ::tolower);
    if (dictionary[word] > 0) {
        filteredText += word;
    }
}
 
void addCharAndReset(char s, string &filteredText, string &word) {
    filteredText += s;  word = "";
    if (s != '\n') {
        filteredText += ' ';
    }
}

int main(int argc, char* argv[])
{
    string outText;
    string imPath = argv[1];

    ifstream fin("dictionary.txt");
    if (!fin) {
	fin.clear();
	cerr << "Error opening file \"" << "dictionary.txt" << "\"!" << endl;
        return 1;
    }
    string word;
    map<string, int> dictionary;
    while(!fin.eof()) {
        fin >> word;
        dictionary[word] = 1;
    }

    fin.close();
 
    // Create Tesseract object
    tesseract::TessBaseAPI *ocr = new tesseract::TessBaseAPI();
     
    // Initialize tesseract to use English (eng) and the LSTM OCR engine. 
    ocr->Init(NULL, "eng", tesseract::OEM_LSTM_ONLY);
 
    // Set Page segmentation mode to PSM_AUTO (3)
    ocr->SetPageSegMode(tesseract::PSM_AUTO);
 
    // Open input image using OpenCV
    Mat im = cv::imread(imPath, IMREAD_COLOR);
   
    // Set image data
    ocr->SetImage(im.data, im.cols, im.rows, 3, im.step);
 
    // Run Tesseract OCR on image
    outText = string(ocr->GetUTF8Text());
    
    /*cout << "====== ORIGINAL TESSERACT OUTPUT =====" << endl;
    cout << outText << endl;
    cout << "++++++++++++++++++++++++++++++++++++++" << endl << endl;*/

    string filteredText;
    word = "";
    for (char s : outText) {
        switch (s) {
            case ' ':
                filterAndAdd(word, dictionary, filteredText);
                filteredText += ' ';
                word = ""; break;
            case '\n':
                filterAndAdd(word, dictionary, filteredText);
                addCharAndReset(s, filteredText, word); break;
            case ',':
                filterAndAdd(word, dictionary, filteredText);
                addCharAndReset(s, filteredText, word); break;
            case '.':
                filterAndAdd(word, dictionary, filteredText);
                addCharAndReset(s, filteredText, word); break;
            case '!':
                filterAndAdd(word, dictionary, filteredText);
                addCharAndReset(s, filteredText, word); break;
            case '?':
                filterAndAdd(word, dictionary, filteredText);
                addCharAndReset(s, filteredText, word); break;
            default:
                word += s;
        }
    }

   /* cout << "====== FILTERED DICTIONARY OUTPUT =====" << endl;
    cout << filteredText << endl;
    cout << "+++++++++++++++++++++++++++++++++++++++" << endl;*/

    ofstream textFile;
    textFile.open ("temp/filteredText.txt");
    textFile << filteredText;
    textFile.close();

    return 0;
}
