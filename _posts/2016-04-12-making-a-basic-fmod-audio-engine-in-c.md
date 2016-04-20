---
title: Making a Basic FMOD Audio Engine in C++
layout: post
---

In my previous post, [Setting Up Xcode and Visual Studio for FMOD Development]({% post_url 2016-04-02-Setting-Up-Xcode-and-Visual-Studio-for-FMOD-Development %}), I talked about getting your IDE enviroment ready for creating an FMOD audio engine implementation. In this tutorial I'll go over creating a basic audio engine that you can use in your C++ projects to add quick and easy dynamic audio. This engine will be able to handle both single audio files and FMOD Studio Events to give you lots of flexibility. So let's get to the code.

{% include toc.html %}

## Engine Organization

This basic engine is going to be broken down into two major parts: an **Implementation** struct that will handle the basic calls to the FMOD API and an **AudioEngine** class that will handle all the logic for loading, unloading, playing, stoping, and changing sounds. When you implement this audio engine into your project the only thing you'll be interacting with is the AudioEngine class. So Let's get started with the header file

## Header File

Now I do want to say I'm not an expert at C++ by any standard. But this being said I'll try to go over everything I did and explain it the best I can. There shouldn't be to many places (if any) that I just don't know why I'm doing it.

So to start off let's create an **AudioEngine.h** file. This will hold all the declarations of our structs and class that we'll use in this engine. So to start out let's put an #ifndef statement at the top of our header and close it off like this...

{% highlight c++ %}

#ifndef _AUDIO_ENGINE_H_
#define _AUDIO_ENGINE_H_



#endif

{% endhighlight %}

What this is doing is checking if **_AUDIO_ENGINE_H_** has been defined before. If it hasn't then go ahead and include all the information in our header. This is to prevent multiple definitions of the objects in our header. If we were to include this header into two different files in our project it would only show up once to the compiler. This is helpful to prevent some weird possible bugs when we compile our code. If you want to know more about this you can check out this [site](http://www.cprogramming.com/tutorial/cpreprocessor.html).

### Using

So now what do we need to include in our header. Well for starters we need the FMOD Studio headers which are **"fmod_studio.hpp"** and **"fmod.hpp"**. Both of these headers are where we'll get all our calls to the FMOD API. Now for engine itself we'll need a few standard library things which are: **<map>**, **<string>**, **<vector>**, and **<math.h>**. Also for debuging and error checking purposes we need to include **<iostream>**. And that is it for the headers we need to include. Your header file should look like this now...

{% highlight c++ %}

#ifndef _AUDIO_ENGINE_H_
#define _AUDIO_ENGINE_H_

#include "fmod_studio.hpp"
#include "fmod.hpp"
#include <string>
#include <map>
#include <vector>
#include <math.h>
#include <iostream>

#endif

{% endhighlight %}

One little line you'll want to include after your usings is

{% highlight c++ %}
using namespace std;
{% endhighlight %}

This will save you a lot of writing Std:: in front of basic items like strings and maps.

### Vector 3

Now that our file knows what we are going to be using let's start creating some basic things in our code the next thing you'll want to create is a struct called **Vector3**. A struct is basically a containeer that we can predefine what variables are going to be in it. We need this **Vector3** struct to place sound in 3D space if our projects require that. So after the **using namespace std;** (and before **#endif**) we'll create our struct...

{% highlight c++ %}
struct Vector3 {
	float x;
	float y;
	float z;
};

{% endhighlight %}

### Implementation

The **Implementation** struct is going to contain most of our calls to the FMOD API. We seperate these calls and the actuall audio engine class itself to try and prevent any weird bugs from popping up. The struct is going to contain the code for initializing and shutting down the FMOD engine as well as hold instances of both the Studio and Low-Level system objects for FMOD. Implemenation will also hold a map of all the sounds and events we've played in our projects. A map is just similar to an array or vector except that all objects are linked to a key. In this case the file name of our event/sound will be the key which will return either the sound or event. And the last thing the struct will do is call an update to FMOD to update the status of all events and sounds. The **Implementation** struct looks like this...

{% highlight c++ %}
struct Implementation {
	Implementation();
	~Implementation();

	void Update();

	FMOD::Studio::System* mpStudioSystem;
	FMOD::System* mpSystem;

	int mnNextChannelId;

	typedef map<string, FMOD::Sound*> SoundMap;
	typedef map<int, FMOD::Channel*> ChannelMap;
	typedef map<string, FMOD::Studio::EventInstance*> EventMap;
	typedef map<string, FMOD::Studio::Bank*> BankMap;

	BankMap mBanks;
	EventMap mEvents;
	SoundMap mSounds;
	ChannelMap mChannels;
};

{% endhighlight %}

### Audio Engine

The last thing in the header is the deffinition of the audio engine. The engine class will do calls to the **Implementation** struct to start, stop, and update FMOD. The engine will also handle basic things like loading, playing, stoping, and updating information on sounds and events. We'll go over each function in more detail when we write the logic behind them. For now the **Audio Engine** class should look like this...

{% highlight c++ %}

class CAudioEngine {
public:
	static void Init();
	static void Update();
	static void Shutdown();
	static int ErrorCheck(FMOD_RESULT result);

	void LoadBank(const string& strBankName, FMOD_STUDIO_LOAD_BANK_FLAGS flags);
	void LoadEvent(const string& strEventName);
	void Loadsound(const string& strSoundName, bool b3d = true, bool bLooping = false, bool bStream = false);
	void UnLoadSound(const string& strSoundName);
	void Set3dListenerAndOrientation(const Vector3& vPos = Vector3{ 0, 0, 0 }, float fVolumedB = 0.0f);
	void PlaySound(const string& strSoundName, const Vector3& vPos = Vector3{ 0, 0, 0 }, float fVolumedB = 0.0f);
	void PlayEvent(const string& strEventName);
	void StopChannel(int nChannelId);
	void StopEvent(const string& strEventName, bool bImmediate = false);
	void GeteventParameter(const string& strEventName, const string% strEventParameter, float* parameter);
	void SetEventParameter(const string& strEventName, const string& strParameterName, flaot fValue);
	void StopAllChannels();
	void SetChannel3dPosition(int nChannelId, const Vector3& vPosition);
	void SetChannelvolume(int nChannelId, float fVolumedB);
	bool IsPlaying(int nChannelId) const;
	bool IsEventPlaying(const string& strEventName) const;
	float dbToVolume(float db);
	float VolumeTodb(float volume);
	FMOD_VECTOR VectorToFmod(const Vector& vPosition);
};

{% endhighlight %}

And that's it for the header file. If you need to look at he full header file you can view it on my [Github](https://github.com/cxsquared/FmodStudioEngine/blob/master/AudioAdventure/include/AudioEngine.h). Now we can get to writing the good stuff. What is acutally going to make our audio engine tick.

## Audio Engine Source Code

Now we can start getting to work on the real task here which is getting sound happening in our project.s
