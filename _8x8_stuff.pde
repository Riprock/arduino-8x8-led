

int pauseDelay = 2; // the number of milliseconds to display each scanned line

// Pin Definitions
// An Array defining which pin each row is attached to
// (rows are common anode (drive HIGH))
int rowA[] = {9, 8, 7, 6, 5, 4, 3, 2};
// An Array defining which pin each column is attached to
// (columns are common cathode (drive LOW))
int colA[] = {10, 11, 12, 13, 14, 15, 16, 17};

char smiley[] = {
	B00111100,
	B01000010,
	B10100101,
	B10000001,
	B10100101,
	B10011001,
	B01000010,
	B00111100
};

char blank[] = {0, 0, 0, 0, 0, 0, 0, 0};

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
	scrollLeft(
		3,
		(char*[]) {
			smiley,
			blank,
			smiley
		},
		1000
	);
}

// Dirty row shower
// Technically there's a flicker of the last columns left on, but hopefully too quick to see
// Clears the row, but not the columns
int flickerRow(int row, char columns) {
	digitalWrite(rowA[row], HIGH);
	for (int i = 0; i < 8; i++) {
		digitalWrite(colA[i], ((columns >> i) & 1) ? LOW : HIGH);
	}
	delay(pauseDelay);
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
// Most accurate times are multiples of pauseDelay * 9
// (that's right, other times are not accurate, but what is these days)
void showSprite(long duration, char sprite[]) {
	long totalTime = 0;
	int flickerTime = pauseDelay * 9;
	while (totalTime < duration) {
		flickerSprite(sprite);
		delay(pauseDelay);
		totalTime += flickerTime;
	}
}

// One sprite to the next
void flipbook(int frames, int frameDuration, char *sprites[]) {
	for (int i = 0; i < frames; i++) {
		showSprite(frameDuration, sprites[i]);
	}
}

// Scrolling sprites
// Whoa, it makes the intermediate sprites
void scrollLeft(int spriteCount, char *sprites[], long oneScrollTime) {
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
