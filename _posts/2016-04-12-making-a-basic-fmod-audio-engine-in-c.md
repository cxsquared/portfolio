---
title: Making a Basic FMOD Audio Engine in C++
layout: post
category: blog
---

In my previous post, [Setting Up Xcode and Visual Studio for FMOD Development]({% post_url 2016-04-02-Setting-Up-Xcode-and-Visual-Studio-for-FMOD-Development %}), I talked about getting your IDE environment ready for creating an FMOD audio engine implementation. In this tutorial I'll go over creating a basic audio engine that you can use in your C++ projects to add quick and easy dynamic audio. This engine will be able to handle both single audio files and FMOD Studio Events to give you lots of flexibility. So let's get to the code.

I will say, like my last tutorial, this isn't a tutorial on how to use [FMOD Studio](http://www.fmod.org/products/). While you'll be able to use FMOD Studio events with this audio engine, this tutorial is solely concentrating on the programming side of FMOD. If you want a good tutorial on FMOD Studio you should check out the tutorial series from my friend Chris Prunotto over on his site [SoundGuyChris.com](http://blog.soundguychris.com/2014/04/15/an-introduction-to-fmod-part-1/).

Also a big shout out to Guy Somberg who inspired me to write these tutorials and actual originally created a lot of this code in his GDC talks. If you have a chance I highly recommend you checking them out on the [GDC Vault](http://gdcvault.com/).

{% include toc.html %}

## Engine Organization

This basic engine is going to be broken down into two major parts: an **Implementation** struct that will handle the basic calls to the FMOD API and an **AudioEngine** class that will handle all the logic for loading, unloading, playing, stopping, and changing sounds. When you implement this audio engine into your project the only thing you'll be interacting with is the AudioEngine class. So Let's get started with the header file.

## Header File

Now I do want to say I'm not an expert at C++ by any standard. But this being said I'll try to go over everything I did and explain it the best I can. If you have any tips or questions feel free to leave them in the comments section at the bottom of the page. I'd love to get your feedback. 

So to start off let's create an **AudioEngine.h** file. This will hold all the declarations of our structs and class that we'll use in this engine. To start out let's put an #ifndef statement at the top of our header and close it off like this:

{% highlight c++ %}

#ifndef _AUDIO_ENGINE_H_
#define _AUDIO_ENGINE_H_



#endif

{% endhighlight %}

What this is doing is checking if **_AUDIO_ENGINE_H_** has been defined before. If it hasn't then go ahead and include all the information in our header. This is to prevent multiple definitions of the objects in our header. If we were to include this header into two different files in our project it would only show up once to the compiler. This is helpful to prevent some weird possible bugs when we compile our code. If you want to know more about this you can check out this [site](http://www.cprogramming.com/tutorial/cpreprocessor.html).

### Includes

So now what do we need to include in our header. Well for starters we need the FMOD Studio headers which are **"fmod_studio.hpp"** and **"fmod.hpp"**. Both of these headers are where we'll get all our calls to the FMOD API. Now for engine itself we'll need a few standard library things which are: **<map>**, **<string>**, **<vector>**, and **<math.h>**. Also for debugging and error checking purposes we need to include **<iostream>**. And that is it for the headers we need to include. Your header file should look like this now:

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

One little line you'll want to include after your Includes is:

{% highlight c++ %}
using namespace std;
{% endhighlight %}

This will save you a lot of writing Std:: in front of basic items like strings and maps.

### Vector 3

Now that our file knows what we are going to be using let's start creating some basic things in our code the next thing you'll want to create is a struct called **Vector3**. A struct is basically a container that we can predefine what variables are going to be in it. We need this **Vector3** struct to place sound in 3D space if our projects require that. So after the **using namespace std;** (and before **#endif**) we'll create our struct:

{% highlight c++ %}
struct Vector3 {
	float x;
	float y;
	float z;
};

{% endhighlight %}

### Implementation

The **Implementation** struct is going to contain most of our calls to the FMOD API. We separate these calls and the actual audio engine class itself to try and prevent any weird bugs from popping up. The struct is going to contain the code for initializing and shutting down the FMOD engine as well as hold instances of both the Studio and Low-Level system objects for FMOD. Implementation will also hold a map of all the sounds and events we've played in our projects. A map is just similar to an array or vector except that all objects are linked to a key. In this case the file name of our event/sound will be the key which will return either the sound or event. And the last thing the struct will do is call an update to FMOD to update the status of all events and sounds. The **Implementation** struct looks like this:

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

The last thing in the header is the deffinition of the audio engine. The engine class will do calls to the **Implementation** struct to start, stop, and update FMOD. The engine will also handle basic things like loading, playing, stoping, and updating information on sounds and events. We'll go over each function in more detail when we write the logic behind them. For now the **Audio Engine** class should look like this:

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

And that's it for the header file. If you need to look at he full header file you can view it on my [Github](https://github.com/cxsquared/FmodStudioEngine/blob/master/AudioAdventure/include/AudioEngine.h). Now we can get to writing the good stuff. What is actually going to make our audio engine tick.

## Audio Engine Source Code

Now we can start getting to work on the real task here which is getting sound happening in our project. The header file was us just telling the program what functions and variables can exists where are source file is what contains the actual logic. Let's start by creating an AudioEngine.cpp file and we'll jump right in.

The first thing we need to do is tell the file that we are using the AudioEngine.h header file. To do with we write:

{% highlight c++ %}

#include "AudioEngine.h"

{% endhighlight %}

### Implementation
This is where we will initialize the underlying FMOD system that will allow us to play sounds. We'll start with the **Implementation** constructor which creates the FMOD Studio and Low-Level systems and set's it's variables.

{% highlight c++ %}

Implementation::Implementation() {
    mpStudioSystem = NULL;
    CAudioEngine::ErrorCheck(FMOD::Studio::System::create(&mpStudioSystem));
    CAudioEngine::ErrorCheck(mpStudioSystem->initialize(32, FMOD_STUDIO_INIT_LIVEUPDATE, FMOD_INIT_PROFILE_ENABLE, NULL));

    mpSystem = NULL;
    CAudioEngine::ErrorCheck(mpStudioSystem->getLowLevelSystem(&mpSystem));
}

{% endhighlight %}

**CAudioEngine::ErrorCheck** is just a way for us to check that all FMOD calls are successful and we'll cover that later. As you can see the first thing we do is create the FMOD Studio System that handles all events and sounds. We then initialize the system and that takes in the number of channels, then flags that can change the way the system runs. The **FMOD_STUDIO_INIT_LIVEUPDATE** is a really cool feature where you can connect to your game with FMOD Studio and live mix the audio. Then to allow us to handle things at a lower level we call **getLowLevelSystem** which gives us the Low-Level system.

Next we create the deconstructor which cleans up FMOD and makes sure we don't leave anything behind. It's super simple and we just unload all assets and then shutdown FMOD.

{% highlight c++ %}

Implementation::~Implementation() {
    CAudioEngine::ErrorCheck(mpStudioSystem->unloadAll());
    CAudioEngine::ErrorCheck(mpStudioSystem->release());
}

{% endhighlight %}

Now we work on the update function of the **Implement** struct. In this function we check if a channel has stopped playing, if it has, we destroy it so we can clear up a channel to use. Other than that we just call the update function on the FMOD system to update the event sounds.

{% highlight c++ %}

void Implementation::Update() {
    vector<ChannelMap::iterator> pStoppedChannels;
    for (auto it = mChannels.begin(), itEnd = mChannels.end(); it != itEnd; ++it)
    {
        bool bIsPlaying = false;
        it->second->isPlaying(&bIsPlaying);
        if (!bIsPlaying)
        {
             pStoppedChannels.push_back(it);
        }
    }
    for (auto& it : pStoppedChannels)
    {
         mChannels.erase(it);
    }
    CAudioEngine::ErrorCheck(mpStudioSystem->update());
}

{% endhighlight %}

And then finally we create an instance of the Implementation so that we can actually use it.

{% highlight c++ %}

Implementation* sgpImplementation = nullptr;

{% endhighlight %}

### Audio Engine

The first two functions we'll add are the **Init** and **Update** functions which are super simple. We just need to create the **Implementation** and call its update.

{% highlight c++ %}

void CAudioEngine::Init() {
    sgpImplementation = new Implementation;
}

void CAudioEngine::Update() {
    sgpImplementation->Update();
}

{% endhighlight %}

Now we need to be able to load sounds. We'll take in the filename along with some parameters about streaming, looping, and whether or not it's a 3D sound and then load that sound and store it in our sound map.

{% highlight c++ %}

void CAudioEngine::LoadSound(const std::string& strSoundName, bool b3d, bool bLooping, bool bStream)
{
    auto tFoundIt = sgpImplementation->mSounds.find(strSoundName);
    if (tFoundIt != sgpImplementation->mSounds.end())
        return;
    
    FMOD_MODE eMode = FMOD_DEFAULT;
    eMode |= b3d ? FMOD_3D : FMOD_2D;
    eMode |= bLooping ? FMOD_LOOP_NORMAL : FMOD_LOOP_OFF;
    eMode |= bStream ? FMOD_CREATESTREAM : FMOD_CREATECOMPRESSEDSAMPLE;
    
    FMOD::Sound* pSound = nullptr;
    CAudioEngine::ErrorCheck(sgpImplementation->mpSystem->createSound(strSoundName.c_str(), eMode, nullptr, &pSound));
    if (pSound){
        sgpImplementation->mSounds[strSoundName] = pSound;
    }

}

{% endhighlight %}

Now we need to be able to unload sounds to free up memory. Luckily unloading is a lot easier. We just take in the file name, look it up in the sound map and release the sound.

{% highlight c++ %}

void CAudioEngine::UnLoadSound(const std::string& strSoundName)
{
    auto tFoundIt = sgpImplementation->mSounds.find(strSoundName);
    if (tFoundIt == sgpImplementation->mSounds.end())
        return;
    
    CAudioEngine::ErrorCheck(tFoundIt->second->release());
    sgpImplementation->mSounds.erase(tFoundIt);
}

{% endhighlight %}

Now we come to the largest function we have which is **PlaySounds**. Even though it's a little large it's actually quite simple. We first see if we have that sound in our sound map. If not we then load it. If we still can't find it then that means something went wrong and we can't play the sound. If we found the sound just fine then we create a new channel to house the sound and tell the sound to play, but we start the sound paused. This is so we don't get a pop in the audio when we set parameters.  If the channel was set right then we update all the possible parameters like volume and position and then unpause the sound. And finally we return the channel id encase we refer to it later.

{% highlight c++ %}

int CAudioEngine::PlaySounds(const string& strSoundName, const Vector3& vPosition, float fVolumedB)
{
    int nChannelId = sgpImplementation->mnNextChannelId++;
    auto tFoundIt = sgpImplementation->mSounds.find(strSoundName);
    if (tFoundIt == sgpImplementation->mSounds.end())
    {
        LoadSound(strSoundName);
        tFoundIt = sgpImplementation->mSounds.find(strSoundName);
        if (tFoundIt == sgpImplementation->mSounds.end())
        {
            return nChannelId;
        }
    }
    FMOD::Channel* pChannel = nullptr;
    CAudioEngine::ErrorCheck(sgpImplementation->mpSystem->playSound(tFoundIt->second, nullptr, true, &pChannel));
    if (pChannel)
    {
        FMOD_MODE currMode;
        tFoundIt->second->getMode(&currMode);
        if (currMode & FMOD_3D){
            FMOD_VECTOR position = VectorToFmod(vPosition);
            CAudioEngine::ErrorCheck(pChannel->set3DAttributes(&position, nullptr));
        }
        CAudioEngine::ErrorCheck(pChannel->setVolume(dbToVolume(fVolumedB)));
        CAudioEngine::ErrorCheck(pChannel->setPaused(false));
        sgpImplementation->mChannels[nChannelId] = pChannel;
    }
    return nChannelId;
}

{% endhighlight %}

The next two functions are simple functions that allow us to set the volume and position of a sound. We just tell it what channel to change and what to change it to.

{% highlight c++ %}

void CAudioEngine::SetChannel3dPosition(int nChannelId, const Vector3& vPosition)
{
    auto tFoundIt = sgpImplementation->mChannels.find(nChannelId);
    if (tFoundIt == sgpImplementation->mChannels.end())
        return;

    FMOD_VECTOR position = VectorToFmod(vPosition);
    CAudioEngine::ErrorCheck(tFoundIt->second->set3DAttributes(&position, NULL));
}

void CAudioEngine::SetChannelVolume(int nChannelId, float fVolumedB)
{
    auto tFoundIt = sgpImplementation->mChannels.find(nChannelId);
    if (tFoundIt == sgpImplementation->mChannels.end())
        return;

    CAudioEngine::ErrorCheck(tFoundIt->second->setVolume(dbToVolume(fVolumedB)));
}

{% endhighlight %}

Now we'll work on loading and playing events. For me events are super powerful tools so I prefer them over programmer sounds. The first thing we have to do is load the banks. Banks are what stores all the sounds and information for each event. We load them much like we loaded the sounds.

{% highlight c++ %}

void CAudioEngine::LoadBank(const std::string& strBankName, FMOD_STUDIO_LOAD_BANK_FLAGS flags) {
    auto tFoundIt = sgpImplementation->mBanks.find(strBankName);
    if (tFoundIt != sgpImplementation->mBanks.end())
        return;
    FMOD::Studio::Bank* pBank;
    CAudioEngine::ErrorCheck(sgpImplementation->mpStudioSystem->loadBankFile(strBankName.c_str(), flags, &pBank));
    if (pBank) {
        sgpImplementation->mBanks[strBankName] = pBank;
    }
}

{% endhighlight %}

The next thing we have to do is load events. Each event stored in a bank has to be loaded separately which helps save memory. We load Events like everything else except we load it in two parts: **EventDescription** and **EventInstance**. The description is the information and the instance is what actually plays the sound.

{% highlight c++ %}

void CAudioEngine::LoadEvent(const std::string& strEventName) {
    auto tFoundit = sgpImplementation->mEvents.find(strEventName);
    if (tFoundit != sgpImplementation->mEvents.end())
        return;
    FMOD::Studio::EventDescription* pEventDescription = NULL;
    CAudioEngine::ErrorCheck(sgpImplementation->mpStudioSystem->getEvent(strEventName.c_str(), &pEventDescription));
    if (pEventDescription){
        FMOD::Studio::EventInstance* pEventInstance = NULL;
        CAudioEngine::ErrorCheck(pEventDescription->createInstance(&pEventInstance));
        if (pEventInstance){
            sgpImplementation->mEvents[strEventName] = pEventInstance;
        }
    }   
}

{% endhighlight %}

Now let's go and play the event. We just look to see that the event has been loaded, if it hasn't we load it, and then tell it to play.

{% highlight c++ %}

void CAudioEngine::PlayEvent(const string &strEventName) {
    auto tFoundit = sgpImplementation->mEvents.find(strEventName);
    if (tFoundit == sgpImplementation->mEvents.end()){
        LoadEvent(strEventName);
        tFoundit = sgpImplementation->mEvents.find(strEventName);
        if (tFoundit == sgpImplementation->mEvents.end())
            return;
    }
    tFoundit->second->start();
}

{% endhighlight %}

We do the same thing for stopping the event except we don't care if it's loaded.

{% highlight c++ %}

void CAudioEngine::StopEvent(const string &strEventName, bool bImmediate) {
    auto tFoundIt = sgpImplementation->mEvents.find(strEventName);
    if (tFoundIt == sgpImplementation->mEvents.end())
        return;
    
    FMOD_STUDIO_STOP_MODE eMode;
    eMode = bImmediate ? FMOD_STUDIO_STOP_IMMEDIATE : FMOD_STUDIO_STOP_ALLOWFADEOUT;
    CAudioEngine::ErrorCheck(tFoundIt->second->stop(eMode));
}

{% endhighlight %}

It's always important to see if an event is playing or not. To do this we have to get the playback state of the event which tells us if it's currently being played.

{% highlight c++ %}

bool CAudioEngine::IsEventPlaying(const string &strEventName) const {
    auto tFoundIt = sgpImplementation->mEvents.find(strEventName);
    if (tFoundIt == sgpImplementation->mEvents.end())
        return false;

    FMOD_STUDIO_PLAYBACK_STATE* state = NULL;
    if (tFoundIt->second->getPlaybackState(state) == FMOD_STUDIO_PLAYBACK_PLAYING) {
        return true;
    }
    return false;
}

{% endhighlight %}

The next two functions really let events shine. It's the ability to get and set parameters of events dynamically. This allows sound designers to create soundscapes for any instance. To do this we just get the event then pass it a string of what parameter we want to see or change and then act accordingly.

{% highlight c++ %}

void CAudioEngine::GetEventParameter(const string &strEventName, const string &strParameterName, float* parameter) {
    auto tFoundIt = sgpImplementation->mEvents.find(strEventName);
    if (tFoundIt == sgpImplementation->mEvents.end())
        return;
    
    FMOD::Studio::ParameterInstance* pParameter = NULL;
    CAudioEngine::ErrorCheck(tFoundIt->second->getParameter(strParameterName.c_str(), &pParameter));
    CAudioEngine::ErrorCheck(pParameter->getValue(parameter));
}

void CAudioEngine::SetEventParameter(const string &strEventName, const string &strParameterName, float fValue) {
    auto tFoundIt = sgpImplementation->mEvents.find(strEventName);
    if (tFoundIt == sgpImplementation->mEvents.end())
        return;
    
    FMOD::Studio::ParameterInstance* pParameter = NULL;
    CAudioEngine::ErrorCheck(tFoundIt->second->getParameter(strParameterName.c_str(), &pParameter));
    CAudioEngine::ErrorCheck(pParameter->setValue(fValue));
}

{% endhighlight %}

Now we have three functions that we've actually being using just to reduce how much code we have to write. These are simple math functions to convert from linear volume to dBs and converting from our Vector3 to FMOD's Vector3.

{% highlight c++ %}

FMOD_VECTOR CAudioEngine::VectorToFmod(const Vector3& vPosition){
    FMOD_VECTOR fVec;
    fVec.x = vPosition.x;
    fVec.y = vPosition.y;
    fVec.z = vPosition.z;
    return fVec;
}

float  CAudioEngine::dbToVolume(float dB)
{
    return powf(10.0f, 0.05f * dB);
}

float  CAudioEngine::VolumeTodB(float volume)
{
    return 20.0f * log10f(volume);
}

{% endhighlight %}

We also have a little function that does FMOD error checking for us. This has come in super handy when something won't load right or the projects sound isn't happening right.

{% highlight c++ %}

int CAudioEngine::ErrorCheck(FMOD_RESULT result) {
    if (result != FMOD_OK){
        cout << "FMOD ERROR " << result << endl;
        return 1;
    }
    // cout << "FMOD all good" << endl;
    return 0;
}

{% endhighlight %}

And finally we just need a function to clean everything up and this just deletes the **Implementation**.

{% highlight c++ %}

void CAudioEngine::Shutdown() {
    delete sgpImplementation;
}

{% endhighlight %}

And that's it!! In under 300 lines of code we have a flexible working audio engine for your projects. Now from here the sky's the limit. Audio is a huge part of any project so you as a programmer should treat it just as importantly as graphics and gameplay. Hopefully this tutorial has helped a bit in that process. Stay tuned for my next tutorial which will be on adding a state machine and some advanced features to our simple audio engine. Feel free to comment down below if you have any tips, tricks, or need help with anything. 

Thanks for reading!
