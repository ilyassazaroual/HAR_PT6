#ifndef GLOBAL_VAR_H
#define GLOBAL_VAR_H

extern int Verbose;
extern int Show;

extern unsigned char sampleBuffer[MAX_SAMPLES][SAMPLE_BUFFER_SIZE];
extern unsigned char imageBuffer[MAX_SAMPLES][IMAGE_BUFFER_SIZE];
extern unsigned char resultBuffer[MAX_SAMPLES][ANALYSIS_BUFFER_SIZE];

// samples
extern int nbSamples;
extern Mat sample_gray[MAX_SAMPLES];
extern char  *sample_windows[MAX_SAMPLES];

// references images
extern int nbImages;
extern Mat image_gray[MAX_IMAGES];
extern char  *image_windows[MAX_SAMPLES];

extern Scalar colorTab[];

enum  optionIndex { UNKNOWN, HELP, OCV };
extern const option::Descriptor usage[];
#endif
