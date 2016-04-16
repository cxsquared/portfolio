---
layout: post
title: Setting Up Xcode and Visual Studio for FMOD Development
tags: FMOD, Audio Programming, Game Development
---

This tutorial series is going to be all about starting out as an Audio Programmer using the middleware [FMOD](http://www.fmod.org/). I'll be going over setting up Xcode/Visual Studio to work with FMOD and creating a basic implementation that you can use in your C++ projects. It's probably good that you have some understanding of C++ but I'll only be covering very basic things so it shouldn't be too hard to follow along if you don't. By the end hopefully you'll have a better grasp on integrating audio middleware into C++ projects so you can start creating some awesome audio programming systems.

I will say this isn't a tutorial on how to use [FMOD Studio](http://www.fmod.org/products/). While you'll be able to use FMOD Studio events with this audio engine, this tutorial is solely concentrating on the programming side of FMOD. If you want a good tutorial on FMOD Studio you should check out the tutorial series from my friend Chris Prunotto over on his site [SoundGuyChris.com](http://blog.soundguychris.com/2014/04/15/an-introduction-to-fmod-part-1/).

## Table of Contents

{% include toc.html %}

## Introduction

For the longest time I've loved both programming and audio so it's only natural that I wanted to delve into the world of audio programming. There's just one problem though... there's a total of about 0 sources on getting into audio programming. I didn't have a background in C++ so reading the API and looking at examples provided by FMOD never really helped me. Every now and then I'd do a new search and look for some beginning tutorials on how to implement FMOD Studio into a game but all that every came up was tools to integrate into [Unity](https://unity3d.com/) or another big engine. And while this is all good and everything for people using those tools I wanted to understand integration at a more basic level. 

Luckily in early 2015 I was lucky enough to get access to the [GDC Vault](http://www.gdcvault.com/) which is a collection of almost all the talks given at each Game Developers Conference. Inside the vault there was a talk given by Guy Somberg, who at that time was working at [Telltale Games](https://www.telltalegames.com/), about creating a basic audio engine. This was exactly what I needed to get my start in the audio programming world. A lot of this tutorial is based off his talk at GDC but from my prospective of coming from almost knowing nothing about C++. Hopefully this will be the tutorial that helps others get started creating cool audio programming things.

## Downloading

The first thing you'll have to do is download the FMOD Studio Programmer API for which ever platform you plan to work on. For this tutorial I'm going to go over setting up your environment for both Xcode on OSX and Visual Studio on Windows. The one down side to using FMOD is that you have to sign-up for their site to download the programmer API though it's still free to use for non-commercial/educational use [(and free for commercial use if you are an indie company.)](http://www.fmod.org/sales/)

So go to the [FMOD.org](http://www.fmod.org/download/) and click the downloads tab. If you scroll down past the FMOD Studio Authoring Tool you'll see the FMOD Studio Programmer's API and Low Level Programmer API. Click the Log In/Register button if you haven't signed in yet and it will take you to the sign in/up page. Once that's done head back to the [downloads page](http://www.fmod.org/download/) and get the version that's right for you. I'll be referring to both the Windows and Macintosh versions for this tutorial.

## Installation

The installation is fairly easy and simple for both platforms. Just open either the .exe or .dmg and follow the steps on the screen. Do remember where you end up installing the files though because we will be referring back to them later.