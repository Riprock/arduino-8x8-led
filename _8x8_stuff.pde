

int pauseDelay = 500; // the number of microseconds to display each scanned line

// Pin Definitions
// An Array defining which pin each row is attached to
// (rows are common anode (drive HIGH))
int rowA[] = {9, 8, 7, 6, 5, 4, 3, 2};
// An Array defining which pin each column is attached to
// (columns are common cathode (drive LOW))
int colA[] = {10, 11, 12, 13, 14, 15, 16, 17};

char _SMILEY[] = {
	B00111100,
	B01000010,
	B10100101,
	B10000001,
	B10100101,
	B10011001,
	B01000010,
	B00111100
};

char _BLANK[] = {0, 0, 0, 0, 0, 0, 0, 0};

// The alphabet
// Each Charachter is an 8 x 8 bitmap where 1 is on and 0 if off
char _A[] = {
	B00010000,
	B00101000,
	B01000100,
	B10000010,
	B11111110,
	B10000010,
	B10000010,
	B00000000
};

char _B[] = {
	B11111100,
	B01000010,
	B01000010,
	B01111100,
	B01000010,
	B01000010,
	B11111100,
	B00000000
};

char _C[] = {
	B00111110,
	B01000000,
	B10000000,
	B10000000,
	B10000000,
	B01000000,
	B00111110,
	B00000000
};

char _D[] = {
	B11111000,
	B01000100,
	B01000010,
	B01000010,
	B01000010,
	B01000100,
	B11111000,
	B00000000
};

char _E[] = {
	B11111110,
	B10000000,
	B10000000,
	B11111000,
	B10000000,
	B10000000,
	B11111110,
	B00000000
};

char _F[] = {
	B11111110,
	B10000000,
	B10000000,
	B11111000,
	B10000000,
	B10000000,
	B10000000,
	B00000000
};

char _G[] = {
	B00111110,
	B01000000,
	B10000000,
	B10011110,
	B10000010,
	B01000010,
	B00111110,
	B00000000
};

char _H[] = {
	B10000010,
	B10000010,
	B10000010,
	B11111110,
	B10000010,
	B10000010,
	B10000010,
	B00000000
};

char _I[] = {
	B11111110,
	B00010000,
	B00010000,
	B00010000,
	B00010000,
	B00010000,
	B11111110,
	B00000000
};

char _J[] = {
	B00011110,
	B00000010,
	B00000010,
	B00000010,
	B00000010,
	B10000010,
	B01111100,
	B00000000
};

char _K[] = {
	B10000110,
	B10001000,
	B10010000,
	B11100000,
	B10010000,
	B10001000,
	B10000110,
	B00000000
};

char _L[] = {
	B10000000,
	B10000000,
	B10000000,
	B10000000,
	B10000000,
	B10000000,
	B11111110,
	B00000000
};

char _M[] = {
	B11101100,
	B10010010,
	B10010010,
	B10010010,
	B10010010,
	B10010010,
	B10010010,
	B00000000
};

char _N[] = {
	B10000010,
	B11000010,
	B10100010,
	B10010010,
	B10001010,
	B10000110,
	B10000010,
	B00000000
};

char _O[] = {
	B00111000,
	B01000100,
	B10000010,
	B10010010,
	B10000010,
	B01000100,
	B00111000,
	B00000000
};

char _P[] = {
	B11111100,
	B01000010,
	B01000010,
	B01111100,
	B01000000,
	B01000000,
	B01000000,
	B00000000
};

char _Q[] = {
	B00111000,
	B01000100,
	B10000010,
	B10000010,
	B10001010,
	B01000100,
	B00111010,
	B00000000
};

char _R[] = {
	B11111100,
	B01000010,
	B01000010,
	B01011100,
	B01001000,
	B01000100,
	B01000010,
	B00000000
};

char _S[] = {
	B01111110,
	B10000000,
	B10000000,
	B01111100,
	B00000010,
	B00000010,
	B11111100,
	B00000000
};

char _T[] = {
	B11111110,
	B00010000,
	B00010000,
	B00010000,
	B00010000,
	B00010000,
	B00010000,
	B00000000
};

char _U[] = {
	B10000010,
	B10000010,
	B10000010,
	B10000010,
	B10000010,
	B10000010,
	B01111100,
	B00000000
};

char _V[] = {
	B10000010,
	B10000010,
	B10000010,
	B10000010,
	B01000100,
	B00101000,
	B00010000,
	B00000000
};

char _W[] = {
	B10000010,
	B10010010,
	B10010010,
	B10010010,
	B10010010,
	B10010010,
	B01101100,
	B00000000
};

char _X[] = {
	B10000010,
	B01000100,
	B00101000,
	B00010000,
	B00101000,
	B01000100,
	B10000010,
	B00000000
};

char _Y[] = {
	B10000010,
	B01000100,
	B00101000,
	B00010000,
	B00010000,
	B00010000,
	B00010000,
	B00000000
};

char _Z[] = {
	B11111110,
	B00000100,
	B00001000,
	B01111100,
	B00100000,
	B01000000,
	B11111110,
	B00000000
};

char* ALPHABET[] = {_A, _B, _C, _D, _E, _F, _G, _H, _I, _J, _K, _L, _M,
                    _N, _O, _P, _Q, _R, _S, _T, _U, _V, _W, _X, _Y, _Z};

void setup()
{ 
	Serial.begin(9600); // Open the Serial port for debugging
	for(int i = 0; i <8; i++){ // 16 pins used to control the array as OUTPUTs
		pinMode(rowA[i], OUTPUT);
		digitalWrite(rowA[i], LOW);
		pinMode(colA[i], OUTPUT);
		digitalWrite(colA[i], HIGH);
	}
}

void loop()
{
	char* sprites[7];
	stringToSprites(7, " HELLO ", sprites);
	scrollLeft(
		7,
		sprites,
		500
	);
}

// Dirty row shower
// Technically there's a flicker of the last columns left on, but hopefully too quick to see
void flickerRow(int row, char columns) {
	digitalWrite(rowA[row], HIGH);
	for (int i = 0; i < 8; i++) {
		if ((columns >> i) & 1) {
			digitalWrite(colA[i], LOW);
			delayMicroseconds(pauseDelay);
			digitalWrite(colA[i], HIGH);
		}
		else digitalWrite(colA[i], HIGH);
	}
	digitalWrite(rowA[row], LOW);
}

// Just flicker some rows
void flickerSprite(char sprite[]) {
	for (int i = 0; i < 8; i++) {
		flickerRow(i, sprite[i]);
	}
}

// Flicker some sprites for a while
// Will block the thread
void showSprite(long duration, char sprite[]) {
	long startTime = millis();
	while (millis() - startTime < duration) {
		flickerSprite(sprite);
		delayMicroseconds(pauseDelay);
	}
}

// One sprite to the next
void flipbook(int frames, int frameDuration, char* sprites[]) {
	for (int i = 0; i < frames; i++) {
		showSprite(frameDuration, sprites[i]);
	}
}

// Scrolling sprites
// Whoa, it makes the intermediate sprites
void scrollLeft(int spriteCount, char* sprites[], long oneScrollTime) {
	// So wonderfully inaccurate at small values
	// Remember how showSprite works too, hoo boy
	long frameDuration = oneScrollTime / 8;
	int totalScrolls = spriteCount - 1;
	for (int i = 0; i < totalScrolls; i++) {
		// 8 stages to the scroll
		for (int j = 0; j < 8; j++) {
			char sprite[8];
			// Do the shifting magic on each row
			for (int k = 0; k < 8; k++) {
				// Check this out
				// Cast unsigned otherwise the top bit gets propagated on >>
				// (which could be a 1 and mess everything up, from experience)
				sprite[k] =
					(sprites[i][k] << j)
					|
					((unsigned char) sprites[i + 1][k] >> (8 - j));
			}
			// We've got a sprite, let's show it
			showSprite(frameDuration, sprite);
		}
	}
}

char* charToSprite(char c) {
	if (c == ' ') return _BLANK;
	return ALPHABET[c - 65];
}

void stringToSprites(int length, char s[], char** sprites) {
	for (int i = 0; i < length; i++) {
		sprites[i] = charToSprite(s[i]);
	}
}
