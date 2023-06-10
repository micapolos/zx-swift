#include "audio.h"
#import <AudioToolbox/AudioToolbox.h>

static AudioQueueRef queueRef;

static const uint32_t bytesPerSample = sizeof(float);
static const uint32_t bufferSize = 1024;
static AudioQueueBufferRef bufferRef;

static void callback(void* user_data, AudioQueueRef queue, AudioQueueBufferRef buffer) {
  printf("Audio Callback");
  uint8_t* ptr = (uint8_t*)buffer->mAudioData;
  for (int i = 0; i < bufferSize; i++) {
    ptr[i] = rand();
  }
  AudioQueueEnqueueBuffer(queueRef, bufferRef, 0, NULL);
}

void zxAudioInit(void) {
  AudioStreamBasicDescription format = {
    .mSampleRate = 44100,
    .mFormatID = kAudioFormatLinearPCM,
    .mFormatFlags = kLinearPCMFormatFlagIsFloat | kAudioFormatFlagIsPacked,
    .mBytesPerPacket = bytesPerSample,
    .mFramesPerPacket = 1,
    .mBytesPerFrame = bytesPerSample,
    .mChannelsPerFrame = 1,
    .mBitsPerChannel = 32,
  };
  
  OSStatus res = AudioQueueNewOutput(&format, callback, 0, NULL, NULL, 0, &queueRef);
  if (res != 0) {
    printf("Error creating audio queue\n");
  }

  res = AudioQueueAllocateBuffer(queueRef, sizeof(float) * bufferSize, &bufferRef);
  if (res != 0) {
    printf("Error allocating audio buffer\n");
  }

  AudioQueueEnqueueBuffer(queueRef, bufferRef, 0, NULL);

  res = AudioQueueStart(queueRef, NULL);
  if (res != 0) {
    printf("Error starting audio\n");
  }
}

void zxAudioDispose(void) {
  AudioQueueStop(queueRef, true);
  AudioQueueDispose(queueRef, true);
}
