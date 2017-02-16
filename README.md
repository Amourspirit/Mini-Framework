# Mini-Framework
Mini-Framework for AutoHotkey

Library of Mini-Framework
Copyright (c) 2013, - 2017 Paul Moss
Licensed under the GNU General Public License GPL-2.0

Requires [AutoHotkey {v1.1.21+}][1]

##Introduction
Mini-Framework is as collection of classes built for [AutoHotkey][1] that help give functionality similar to a strongly typed language. The MfType class can be used to get information from an object. All objects have a GetType() method that returns an instance of the MfType class. All object inherit from MfObject and therefore inherit all the methods of MfObject.

Mini-Framework attempts to bridge the gap between the powerful scripting language of [AutoHotkey][1] and a more strongly typed language. The classes are built in a Mono/.Net style.

The Mini-Framework classes are built with the power of strongly type object while maintaining flexibility with AutoHotkey variables. Many of the classes accept variables in their methods, constructors and overloads methods to make using this framework flexible.

All the Classes are prefixed with Mf to help avoid any conflicts with naming conventions and variables in existing projects.

There is also a package available for Sublime Text to give intellisense and syntax highlighting to Mini-Framework.

All objects derived from MfObject use a Zero-Based index.
###Installation
Installation of Mini-Framework is simple and can be installed with a single installer.  
Download the lstest version of [MfSetup.exe][4]

###Getting Help
There is a package available for [Sublime Text][2] intellisense for user of [Sublime Text][2].  
Help is available online and as a separate help file and can also be accesed online [here][3]
###Getting started
Adding Mini-Framework to your project is as simple as adding `#Include <inc_mf_0_3>` in the top of your script.

To include othe namespaces sucas as System.IO and the include for theat namespace.  
`#Include <inc_mf_System_IO_0_3>`

####AutoHotkey Snippit
AutoHotkey Snippit is an automation program that also has a template available to quickly accesss help for kewords in both AutoHotkey and Mini-Framework. Onece AutoHotkey Snippit is installed and the templet is set you can simply get help for any AutoHotkey keyworkd or any Mini-Framework class / keyword by pressing a shortcut key. AutoHotkey Snippit can be set to work with any editor that you choose to write [AutoHotkey][1] code in.

####Future Versions
Future version of Mini-Framework will not interfere with current versions as each version in separated.

####Distribution
See the [help][3] file for information on how to distribute with your application or project.


[1]:https://autohotkey.com
[2]:http://www.sublimetext.com
[3]:https://amourspirit.github.io/Mini-Framework/
[4]:https://github.com/Amourspirit/Mini-Framework/raw/master/Latest/stable/0.3x/MfSetup.exe