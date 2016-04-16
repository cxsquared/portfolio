---
title: Making a Basic FMOD Audio Engine in C++
layout: post
---

In my previous post, [Setting Up Xcode and Visual Studio for FMOD Development]({% post_url 2016-04-02-Setting-Up-Xcode-and-visual-Studio-for-FMOD-Development. %}), I talked about getting your IDE enviroment ready for creating an FMOD audio engine implementation. In this tutorial I'll go over creating a basic audio engine that you can use in your C++ projects to add quick and easy dynamic audio. This engine will be able to handle both single audio files and FMOD Studio Events to give you lots of flexibility. So let's get to the code.

## Table of Contents

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

What this is doing is checking if _AUDIO_ENGINE_H_ has been defined before. If it hasn't then go ahead and include all the information in our header. This is to prevent multiple definitions of the objects in our header. If we were to include this header into two different files in our project it would only show up once to the compiler. This is helpful to prevent some weird possible bugs when we compile our code. If you want to know more about this you can check out this [site](http://www.cprogramming.com/tutorial/cpreprocessor.html).

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
