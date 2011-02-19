// Liquid Sting font adapted from http://www.theiling.de/projects/liquid.html 
// under GPL v.3 license.

struct liquid_sting_glyph {
	int first : 4; /* first column to be displayed in proportional mode */
	int last :  4; /* last	column to be displayed in proportional mode */
	byte data[6] ; /* column data */
};

int pauseDelay = 500; // the number of microseconds to display each scanned line

// Pin Definitions
// An Array defining which pin each row is attached to
// (rows are common anode (drive HIGH))
int rowA[] = {9, 8, 7, 6, 5, 4, 3, 2};
// An Array defining which pin each column is attached to
// (columns are common cathode (drive LOW))
int colA[] = {17, 16, 15, 14, 13, 12, 11, 10};

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

char message[141] = "It's tricky to rock a rhyme to rock a rhyme that's right "
                    "on time it's tricky. It's tricky, tricky, tricky.";
int messageLength = 106;

void loop()
{
	int available = Serial.available();
	if (available) {
		int i;
		for (i = 0; i < available; i++) {
			message[i] = Serial.read();
		}
		message[i] = NULL;
		messageLength = i;
	}
	scrollLeftStingMessage(
		messageLength,
		message,
		63
	);
}

// Dirty row shower
void flickerRow(int row, byte columns) {
	digitalWrite(rowA[row], HIGH);
	for (int i = 0; i < 8; i++) {
		if ((columns << i) & 128) {
			digitalWrite(colA[i], LOW);
			delayMicroseconds(pauseDelay);
			digitalWrite(colA[i], HIGH);
		}
		else digitalWrite(colA[i], HIGH);
	}
	digitalWrite(rowA[row], LOW);
}

// Just flicker some rows
void flickerSprite(byte sprite[]) {
	for (int i = 0; i < 8; i++) {
		flickerRow(i, sprite[i]);
	}
}

// Flicker some sprites for a while
// Will block the thread
void showSprite(long duration, byte sprite[]) {
	long startTime = millis();
	while (millis() - startTime < duration) {
		flickerSprite(sprite);
		delayMicroseconds(pauseDelay);
	}
}

// Columns are options too
void flickerColumn(int column, byte rows) {
	digitalWrite(colA[column], LOW);
	for (int i = 0; i < 8; i++) {
		if ((rows >> i) & 1) {
			digitalWrite(rowA[i], HIGH);
			delayMicroseconds(pauseDelay);
			digitalWrite(rowA[i], LOW);
		}
		else digitalWrite(rowA[i], LOW);
	}
	digitalWrite(colA[column], HIGH);
}

void flickerColumns(byte columns[]) {
	for (int i = 0; i < 8; i++) {
		flickerColumn(i, columns[i]);
	}
}

void showColumns(long duration, byte columns[]) {
	long startTime = millis();
	while (millis() - startTime < duration) {
		flickerColumns(columns);
		delayMicroseconds(pauseDelay);
	}
}

// One sprite to the next
void flipbook(int frames, int frameDuration, byte* sprites[]) {
	for (int i = 0; i < frames; i++) {
		showSprite(frameDuration, sprites[i]);
	}
}

// Scrolling sprites
// Whoa, it makes the intermediate sprites
void scrollLeft(int spriteCount, byte* sprites[], long oneScrollTime) {
	// So wonderfully inaccurate at small values
	// Remember how showSprite works too, hoo boy
	long frameDuration = oneScrollTime / 8;
	int totalScrolls = spriteCount - 1;
	for (int i = 0; i < totalScrolls; i++) {
		// 8 stages to the scroll
		for (int j = 0; j < 8; j++) {
			byte sprite[8];
			// Do the shifting magic on each row
			for (int k = 0; k < 8; k++) {
				// Check this out
				// Cast unsigned otherwise the top bit gets propagated on >>
				// (which could be a 1 and mess everything up, from experience)
				sprite[k] =
					(sprites[i][k] << j) | (sprites[i + 1][k] >> (8 - j));
			}
			// We've got a sprite, let's show it
			showSprite(frameDuration, sprite);
		}
	}
}

void stringToSprites(char s[], byte** sprites) {
	int i = 0;
	while(s[i] != NULL) {
		sprites[i] = charToSprite(s[i]);
		i++;
	}
}

void scrollLeftStingMessage(
	int messageLength, char message[], int columnDuration)
{
	struct liquid_sting_glyph glyphs[messageLength];
	stringToLiquidStingGlyphs(message, glyphs);
	byte columns[] = {0, 0, 0, 0, 0, 0, 0, 0};
	for (int i = 0; i < messageLength; i++) {
		int glyphEnd = 6 - glyphs[i].last;
		for (int j = glyphs[i].first; j < glyphEnd; j++) {
			for (int k = 1; k < 8; k++) {
				columns[k - 1] = columns[k];
			}
			columns[7] = glyphs[i].data[j];
			showColumns(columnDuration, columns);
		}
		for (int k = 1; k < 8; k++) {
			columns[k - 1] = columns[k];
		}
		columns[7] = 0;
		showColumns(columnDuration, columns);
	}
	for (int i = 0; i < 7; i++) {
		for (int k = 1; k < 8; k++) {
			columns[k - 1] = columns[k];
		}
		columns[7] = 0;
		showColumns(columnDuration, columns);
	}
}

byte _SMILEY[] = {
	B00111100,
	B01000010,
	B10100101,
	B10000001,
	B10100101,
	B10011001,
	B01000010,
	B00111100
};

byte _BLANK[] = {0, 0, 0, 0, 0, 0, 0, 0};

// The alphabet
// Each Charachter is an 8 x 8 bitmap where 1 is on and 0 if off
byte _A[] = {
	B00010000,
	B00101000,
	B01000100,
	B10000010,
	B11111110,
	B10000010,
	B10000010,
	B00000000
};

byte _B[] = {
	B11111100,
	B01000010,
	B01000010,
	B01111100,
	B01000010,
	B01000010,
	B11111100,
	B00000000
};

byte _C[] = {
	B00111110,
	B01000000,
	B10000000,
	B10000000,
	B10000000,
	B01000000,
	B00111110,
	B00000000
};

byte _D[] = {
	B11111000,
	B01000100,
	B01000010,
	B01000010,
	B01000010,
	B01000100,
	B11111000,
	B00000000
};

byte _E[] = {
	B11111110,
	B10000000,
	B10000000,
	B11111000,
	B10000000,
	B10000000,
	B11111110,
	B00000000
};

byte _F[] = {
	B11111110,
	B10000000,
	B10000000,
	B11111000,
	B10000000,
	B10000000,
	B10000000,
	B00000000
};

byte _G[] = {
	B00111110,
	B01000000,
	B10000000,
	B10011110,
	B10000010,
	B01000010,
	B00111110,
	B00000000
};

byte _H[] = {
	B10000010,
	B10000010,
	B10000010,
	B11111110,
	B10000010,
	B10000010,
	B10000010,
	B00000000
};

byte _I[] = {
	B11111110,
	B00010000,
	B00010000,
	B00010000,
	B00010000,
	B00010000,
	B11111110,
	B00000000
};

byte _J[] = {
	B00011110,
	B00000010,
	B00000010,
	B00000010,
	B00000010,
	B10000010,
	B01111100,
	B00000000
};

byte _K[] = {
	B10000110,
	B10001000,
	B10010000,
	B11100000,
	B10010000,
	B10001000,
	B10000110,
	B00000000
};

byte _L[] = {
	B10000000,
	B10000000,
	B10000000,
	B10000000,
	B10000000,
	B10000000,
	B11111110,
	B00000000
};

byte _M[] = {
	B11101100,
	B10010010,
	B10010010,
	B10010010,
	B10010010,
	B10010010,
	B10010010,
	B00000000
};

byte _N[] = {
	B10000010,
	B11000010,
	B10100010,
	B10010010,
	B10001010,
	B10000110,
	B10000010,
	B00000000
};

byte _O[] = {
	B00111000,
	B01000100,
	B10000010,
	B10010010,
	B10000010,
	B01000100,
	B00111000,
	B00000000
};

byte _P[] = {
	B11111100,
	B01000010,
	B01000010,
	B01111100,
	B01000000,
	B01000000,
	B01000000,
	B00000000
};

byte _Q[] = {
	B00111000,
	B01000100,
	B10000010,
	B10000010,
	B10001010,
	B01000100,
	B00111010,
	B00000000
};

byte _R[] = {
	B11111100,
	B01000010,
	B01000010,
	B01011100,
	B01001000,
	B01000100,
	B01000010,
	B00000000
};

byte _S[] = {
	B01111110,
	B10000000,
	B10000000,
	B01111100,
	B00000010,
	B00000010,
	B11111100,
	B00000000
};

byte _T[] = {
	B11111110,
	B00010000,
	B00010000,
	B00010000,
	B00010000,
	B00010000,
	B00010000,
	B00000000
};

byte _U[] = {
	B10000010,
	B10000010,
	B10000010,
	B10000010,
	B10000010,
	B10000010,
	B01111100,
	B00000000
};

byte _V[] = {
	B10000010,
	B10000010,
	B10000010,
	B10000010,
	B01000100,
	B00101000,
	B00010000,
	B00000000
};

byte _W[] = {
	B10000010,
	B10010010,
	B10010010,
	B10010010,
	B10010010,
	B10010010,
	B01101100,
	B00000000
};

byte _X[] = {
	B10000010,
	B01000100,
	B00101000,
	B00010000,
	B00101000,
	B01000100,
	B10000010,
	B00000000
};

byte _Y[] = {
	B10000010,
	B01000100,
	B00101000,
	B00010000,
	B00010000,
	B00010000,
	B00010000,
	B00000000
};

byte _Z[] = {
	B11111110,
	B00000100,
	B00001000,
	B01111100,
	B00100000,
	B01000000,
	B11111110,
	B00000000
};

byte* ALPHABET[] = {_A, _B, _C, _D, _E, _F, _G, _H, _I, _J, _K, _L, _M,
                    _N, _O, _P, _Q, _R, _S, _T, _U, _V, _W, _X, _Y, _Z};

byte* charToSprite(char c) {
	if (c == ' ') return _BLANK;
	return ALPHABET[c - 65];
}

struct liquid_sting_glyph STING_ALPHABET[] = {
	{1, 1, {0x00, 0x00, 0x00, 0x00, 0x00, 0x00}},
	{3, 2, {0x00, 0x00, 0x00, 0x2f, 0x00, 0x00}},
	{2, 1, {0x00, 0x00, 0x03, 0x00, 0x03, 0x00}},
	{1, 0, {0x00, 0x12, 0x3f, 0x12, 0x3f, 0x12}},
	{1, 1, {0x00, 0x24, 0x7a, 0x2f, 0x12, 0x00}},
	{1, 2, {0x00, 0x12, 0x08, 0x24, 0x00, 0x00}},
	{1, 0, {0x00, 0x1a, 0x25, 0x2a, 0x10, 0x28}},
	{3, 2, {0x00, 0x00, 0x00, 0x03, 0x00, 0x00}},
	{2, 2, {0x00, 0x00, 0x1e, 0x21, 0x00, 0x00}},
	{2, 2, {0x00, 0x00, 0x21, 0x1e, 0x00, 0x00}},
	{2, 1, {0x00, 0x00, 0x2a, 0x1c, 0x2a, 0x00}},
	{2, 1, {0x00, 0x00, 0x08, 0x1c, 0x08, 0x00}},
	{2, 2, {0x00, 0x00, 0x40, 0x30, 0x00, 0x00}},
	{2, 2, {0x00, 0x00, 0x08, 0x08, 0x00, 0x00}},
	{3, 2, {0x00, 0x00, 0x00, 0x20, 0x00, 0x00}},
	{1, 2, {0x00, 0x30, 0x0c, 0x03, 0x00, 0x00}},
	{2, 1, {0x00, 0x00, 0x1e, 0x21, 0x1e, 0x00}},
	{2, 1, {0x00, 0x00, 0x02, 0x3f, 0x00, 0x00}},
	{2, 1, {0x00, 0x00, 0x31, 0x29, 0x26, 0x00}},
	{2, 1, {0x00, 0x00, 0x21, 0x25, 0x1b, 0x00}},
	{2, 1, {0x00, 0x00, 0x0e, 0x08, 0x3f, 0x00}},
	{2, 1, {0x00, 0x00, 0x27, 0x25, 0x19, 0x00}},
	{2, 1, {0x00, 0x00, 0x1e, 0x25, 0x19, 0x00}},
	{2, 1, {0x00, 0x00, 0x01, 0x39, 0x07, 0x00}},
	{2, 1, {0x00, 0x00, 0x1a, 0x25, 0x1a, 0x00}},
	{2, 1, {0x00, 0x00, 0x26, 0x29, 0x1e, 0x00}},
	{3, 2, {0x00, 0x00, 0x00, 0x24, 0x00, 0x00}},
	{2, 2, {0x00, 0x00, 0x80, 0x64, 0x00, 0x00}},
	{2, 1, {0x00, 0x00, 0x08, 0x14, 0x22, 0x00}},
	{2, 1, {0x00, 0x00, 0x14, 0x14, 0x14, 0x00}},
	{2, 1, {0x00, 0x00, 0x22, 0x14, 0x08, 0x00}},
	{2, 1, {0x00, 0x00, 0x29, 0x05, 0x02, 0x00}},
	{1, 0, {0x00, 0x3e, 0x41, 0x49, 0x55, 0x1e}},
	{2, 1, {0x00, 0x00, 0x3e, 0x09, 0x3e, 0x00}},
	{2, 1, {0x00, 0x00, 0x3f, 0x25, 0x1a, 0x00}},
	{2, 1, {0x00, 0x00, 0x1e, 0x21, 0x21, 0x00}},
	{2, 1, {0x00, 0x00, 0x3f, 0x21, 0x1e, 0x00}},
	{2, 1, {0x00, 0x00, 0x3f, 0x25, 0x21, 0x00}},
	{2, 1, {0x00, 0x00, 0x3f, 0x05, 0x01, 0x00}},
	{2, 1, {0x00, 0x00, 0x1e, 0x21, 0x39, 0x00}},
	{2, 1, {0x00, 0x00, 0x3f, 0x04, 0x3f, 0x00}},
	{3, 2, {0x00, 0x00, 0x21, 0x3f, 0x21, 0x00}},
	{2, 2, {0x00, 0x00, 0x40, 0x3f, 0x00, 0x00}},
	{2, 1, {0x00, 0x00, 0x3f, 0x04, 0x3b, 0x00}},
	{2, 1, {0x00, 0x00, 0x3f, 0x20, 0x20, 0x00}},
	{1, 0, {0x00, 0x3f, 0x02, 0x04, 0x02, 0x3f}},
	{1, 1, {0x00, 0x3f, 0x02, 0x04, 0x3f, 0x00}},
	{2, 1, {0x00, 0x00, 0x1e, 0x21, 0x1e, 0x00}},
	{2, 1, {0x00, 0x00, 0x3f, 0x09, 0x06, 0x00}},
	{2, 1, {0x00, 0x00, 0x1e, 0x61, 0x5e, 0x00}},
	{2, 1, {0x00, 0x00, 0x3f, 0x09, 0x36, 0x00}},
	{2, 1, {0x00, 0x00, 0x22, 0x25, 0x19, 0x00}},
	{2, 1, {0x00, 0x00, 0x01, 0x3f, 0x01, 0x00}},
	{2, 1, {0x00, 0x00, 0x1f, 0x20, 0x3f, 0x00}},
	{2, 1, {0x00, 0x00, 0x3f, 0x10, 0x0f, 0x00}},
	{1, 0, {0x00, 0x1f, 0x20, 0x18, 0x20, 0x1f}},
	{2, 1, {0x00, 0x00, 0x33, 0x0c, 0x33, 0x00}},
	{2, 1, {0x00, 0x00, 0x07, 0x38, 0x07, 0x00}},
	{2, 1, {0x00, 0x00, 0x31, 0x2d, 0x23, 0x00}},
	{2, 2, {0x00, 0x00, 0x3f, 0x21, 0x00, 0x00}},
	{2, 1, {0x00, 0x00, 0x03, 0x0c, 0x30, 0x00}},
	{2, 2, {0x00, 0x00, 0x21, 0x3f, 0x00, 0x00}},
	{1, 0, {0x00, 0x04, 0x02, 0x3f, 0x02, 0x04}},
	{2, 1, {0x00, 0x00, 0x40, 0x40, 0x40, 0x00}},
	{1, 1, {0x00, 0x24, 0x3e, 0x25, 0x21, 0x00}},
	{2, 1, {0x00, 0x00, 0x18, 0x24, 0x3c, 0x00}},
	{2, 1, {0x00, 0x00, 0x3f, 0x24, 0x18, 0x00}},
	{2, 2, {0x00, 0x00, 0x18, 0x24, 0x00, 0x00}},
	{2, 1, {0x00, 0x00, 0x18, 0x24, 0x3f, 0x00}},
	{2, 1, {0x00, 0x00, 0x18, 0x34, 0x2c, 0x00}},
	{3, 1, {0x00, 0x00, 0x00, 0x3e, 0x05, 0x00}},
	{2, 1, {0x00, 0x00, 0x98, 0xa4, 0x7c, 0x00}},
	{2, 1, {0x00, 0x00, 0x3f, 0x04, 0x38, 0x00}},
	{3, 2, {0x00, 0x00, 0x00, 0x3d, 0x00, 0x00}},
	{2, 2, {0x00, 0x00, 0x80, 0x7d, 0x00, 0x00}},
	{2, 1, {0x00, 0x00, 0x3f, 0x08, 0x34, 0x00}},
	{3, 2, {0x00, 0x00, 0x01, 0x3f, 0x00, 0x00}},
	{1, 0, {0x00, 0x3c, 0x04, 0x3c, 0x04, 0x38}},
	{2, 1, {0x00, 0x00, 0x3c, 0x04, 0x38, 0x00}},
	{2, 1, {0x00, 0x00, 0x18, 0x24, 0x18, 0x00}},
	{2, 1, {0x00, 0x00, 0xfc, 0x24, 0x18, 0x00}},
	{2, 1, {0x00, 0x00, 0x18, 0x24, 0xfc, 0x00}},
	{2, 2, {0x00, 0x00, 0x38, 0x04, 0x00, 0x00}},
	{2, 2, {0x00, 0x00, 0x2c, 0x34, 0x00, 0x00}},
	{2, 2, {0x00, 0x00, 0x1e, 0x24, 0x00, 0x00}},
	{2, 1, {0x00, 0x00, 0x1c, 0x20, 0x3c, 0x00}},
	{2, 1, {0x00, 0x00, 0x3c, 0x10, 0x0c, 0x00}},
	{1, 0, {0x00, 0x1c, 0x20, 0x18, 0x20, 0x1c}},
	{2, 1, {0x00, 0x00, 0x24, 0x18, 0x24, 0x00}},
	{2, 1, {0x00, 0x00, 0x9c, 0x60, 0x1c, 0x00}},
	{2, 2, {0x00, 0x00, 0x34, 0x2c, 0x00, 0x00}},
	{2, 1, {0x00, 0x00, 0x04, 0x3b, 0x21, 0x00}},
	{3, 2, {0x00, 0x00, 0x00, 0x3f, 0x00, 0x00}},
	{1, 2, {0x00, 0x21, 0x3b, 0x04, 0x00, 0x00}},
	{1, 1, {0x00, 0x02, 0x01, 0x02, 0x01, 0x00}}
};

struct liquid_sting_glyph charToLiquidStingGlyph(char c) {
	return STING_ALPHABET[c - 32];
}

void stringToLiquidStingGlyphs(char s[], struct liquid_sting_glyph* glyphs) {
	int i = 0;
	while(s[i] != NULL) {
		glyphs[i] = charToLiquidStingGlyph(s[i]);
		i++;
	}
}
	