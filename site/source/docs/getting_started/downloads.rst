.. _sdk-download-and-install:

======================================================
Download and install (ready-for-review) 
======================================================

**The Emscripten SDK provides the whole Emscripten toolchain (Clang, Python, Node.js and Visual Studio integration) in a single easy-to-install package, with integrated support for** :ref:`updating to newer SDKs <updating-the-emscripten-sdk>` **as they are released.**

.. tip:: If you are :ref:`contributing <contributing>` to Emscripten you should first install the SDK, and then use it to :ref:`build Emscripten from source <building-emscripten-from-source-using-the-sdk>`.


SDK Downloads
==================

Download one of the SDK installers below to get started with Emscripten development. The Windows NSIS installers are the easiest to set up, while the portable SDKs can be moved between computers and do not require administration privileges. 

.. emscripten-sdk-windows-installers:

Windows
-------

- `Emscripten SDK Web Installer  <https://s3.amazonaws.com/mozilla-games/emscripten/releases/emsdk-1.22.0-web-64bit.exe>`_ (emsdk-1.22.0-web-64bit.exe)
		An NSIS installer that fetches and installs the latest Emscripten SDK from the web. To :ref:`install <windows-installation_instructions-NSIS>`, download and open the file, then follow the installer prompts.

- `Emscripten SDK Offline Installer <https://s3.amazonaws.com/mozilla-games/emscripten/releases/emsdk-1.22.0-full-64bit.exe>`_ (emsdk-1.22.0-full-64bit.exe)
		An NSIS installer that bundles together the current Emscripten toolchain as an offline-installable package. To :ref:`install <windows-installation_instructions-NSIS>`, download and open the file, then follow the installer prompts.

- `Portable Emscripten SDK for Windows <https://s3.amazonaws.com/mozilla-games/emscripten/releases/emsdk-1.22.0-portable-64bit.zip>`_ (emsdk-1.22.0-portable-64bit.zip)
		A zipped package of the SDK that does not require system installation privileges. To install, follow :ref:`these <all-os-installation_instructions-portable-SDK>` instructions.

Linux and Mac OS X
------------------

.. _portable-emscripten-sdk-linux-osx:
	
- `Portable Emscripten SDK for Linux and OS X <https://s3.amazonaws.com/mozilla-games/emscripten/releases/emsdk-portable.tar.gz>`_ (emsdk-portable.tar.gz) 
		A tar.gz archive package of the SDK that does not require system installation privileges. To install, follow :ref:`the general instructions <all-os-installation_instructions-portable-SDK>` and :ref:`platform-specific notes <platform-notes-installation_instructions-portable-SDK>`.



.. _sdk-installation-instructions:

Installation instructions
=========================

Check the relevant section below for instructions on installing your selected package. 

.. _windows-installation_instructions-NSIS:

Windows: Installing using an NSIS installer
--------------------------------------------

The NSIS installers register the Emscripten SDK as a *standard* Windows application. To install the SDK, download an NSIS **.exe** file, double-click on it, and run through the installer to perform the installation. 

After the installer finishes, the full Emscripten toolchain will be available in the directory that was chosen during the installation, and no other steps are necessary. If your system has *Visual Studio 2010* installed, the :term:`vs-tool` MSBuild plugin will be automatically installed as well.


.. _all-os-installation_instructions-portable-SDK:

Windows, OSX and Linux: Installing the Portable SDK
----------------------------------------------------

The *Portable Emscripten SDK* is a no-installer version of the SDK package. It is identical to the NSIS installer, except that it does not interact with the Windows registry. This allows Emscripten to be used on a computer without administrative privileges, and means that the installation can be migrated from one location (directory or computer) to another by simply copying the directory contents to the new location.

First check the :ref:`Platform-specific notes <platform-notes-installation_instructions-portable-SDK>` below and install any prerequisites.

Install the SDK using the following steps:

1. Download and unzip the portable SDK package to a directory of your choice. This directory will contain the Emscripten SDK.
#. Open a command prompt inside the SDK directory and run the following :ref:`emsdk <emsdk>` commands to get the latest SDK tools and set them as :term:`active <Active Tool/SDK>`. 

	.. note:: On Windows, invoke the tool with **emsdk** instead of **./emsdk**: 
	
	::

		# Fetch the latest registry of available tools.
		./emsdk update
		
		# Download and install the latest SDK tools.
		./emsdk install latest

		# Make the "latest" SDK "active"
		./emsdk activate latest	

Whenever you change the location of the Portable SDK (e.g. take it to another computer), re-run the final command: ``./emsdk activate latest``.

.. tip:: The instructions above can also be used to get new SDKs, as they are released.


.. _platform-notes-installation_instructions-portable-SDK:

Platform-specific notes
----------------------------

Mac OS X
++++++++

- *Git* is not installed automatically. Git is only needed if you want to use tools from one of the development branches: **emscripten-incoming** or **emscripten-master** directly. To install *git* on OSX:
   
	1. Install *XCode* and the *XCode Command Line Tools*. This will provide *git* to the system PATH. For more help on this step, see `this stackoverflow post <http://stackoverflow.com/questions/9329243/xcode-4-4-command-line-tools>`_.
	2. Install git directly from http://git-scm.com/.

- *Java* is not bundled with the Emscripten SDK. After installing Emscripten via :ref:`emsdk <emsdk>`, typing ``./emcc --help`` should pop up a dialog that will automatically download a Java Runtime to the system: ::

	Java is not installed. To open Java, you need a Java SE 6 runtime. 
	Would you like to install one now?
	
- The *python2* command line tool is not present on OSX by default. To manually work around this issue, follow the linked step in :ref:`Getting started on Mac OS X <getting-started-on-osx-install-python2>`.

.. **HamishW**: I think that Mac OS X has the same issues as Linux - ie you don't get ANYTHING much in the SDK. YOu will need the command line tools, but mostly for GCC - need to confirm this with Jukka

Linux
++++++++

.. note:: Pre-built binaries of tools are not available on Linux. Installing a tool will automatically clone and build that tool from the sources inside the **emsdk** directory. *Emsdk* does not interact with Linux package managers on the behalf of the user, nor does it install any tools to the system. All file changes are done inside the **emsdk/** directory.

- The system must have a working :ref:`compiler-toolchain` (because *emsdk* builds software from the source): 

	::	
	
		#Update the package lists
		sudo apt-get update
		
		# Install *gcc* (and related dependencies)
		sudo apt-get install build-essential		
		# Install cmake
		sudo apt-get install cmake
		
		
- *Python*, *node.js* or *Java* are not provided by *emsdk*. The user is expected to install these beforehand with the *system package manager*:

	::
	
		# Install Python 
		sudo apt-get install python2.7
		# Install node.js
		sudo apt-get install nodejs
		# Install Java
		sudo apt-get install default-jre
		
- *Git* is not installed automatically. Git is only needed if you want to use tools from one of the development branches **emscripten-incoming** or **emscripten-master**: 

	::
	
		# Install git
		sudo apt-get install git-core

More detailed instructions on the toolchain are provided in: :ref:`building-emscripten-on-linux`.


Verifying the installation
==========================

The easiest way to verify the installation is to compile some code using Emscripten. 

You can jump ahead to the :ref:`Tutorial`, but if you have any problems building you should run through the basic tests and troubleshooting instructions in :ref:`verifying-the-emscripten-environment`.


.. _updating-the-emscripten-sdk:

Updating the SDK
================

.. tip:: You only need to install the SDK once! After that you can update to the latest SDK at any time using the :ref:`SDK Package Manager (emsdk) <emsdk>`. 

Type the following (omitting comments) on the :ref:`Emscripten Command Prompt <emcmdprompt>`: ::

	# Fetch the latest registry of available tools.
	./emsdk update
	# Download and install the latest SDK tools.
	./emsdk install latest
	# Set up the compiler configuration to point to the "latest" SDK.
	./emsdk activate latest

The package manager can do many other maintenance tasks ranging from fetching specific old versions of the SDK through to using the :ref:`versions of the tools on Github <emsdk-master-or-incoming-sdk>` (or even your own fork). Check out all the possibilities in the :ref:`emsdk_howto`.

.. _downloads-uninstall-the-sdk:

Uninstalling the Emscripten SDK
========================================================

If you installed the SDK using an NSIS installer on Windows, launch: **Control Panel -> Uninstall a program -> Emscripten SDK**.

If you want to remove a Portable SDK, just delete the directory containing the Portable SDK.

It is also possible to :ref:`remove specific SDKs using emsdk <emsdk-remove-tool-sdk>`.


.. _archived-nsis-windows-sdk-releases:

Archived releases
=================
 
You can always install old SDK and compiler toolchains via the latest :ref:`emsdk <emsdk-get-latest-sdk>`. If you need to fall back to an old version, download the Portable SDK version and use that to install a previous version of a tool. All old tool versions are available by typing ``emsdk list --old``.

On Windows, you can also install one of the **old versions** via an offline NSIS installer:

- `emsdk-1.16.0-full-64bit.exe <https://s3.amazonaws.com/mozilla-games/emscripten/releases/emsdk-1.16.0-full-64bit.exe>`_ (first stable fastcomp release) 
- `emsdk-1.13.0-full-32bit.exe <https://s3.amazonaws.com/mozilla-games/emscripten/releases/emsdk-1.13.0-full-64bit.exe>`_ (a unstable first fastcomp release with Clang 3.3)
- `emsdk-1.12.0-full-64bit.exe <https://s3.amazonaws.com/mozilla-games/emscripten/releases/emsdk-1.12.0-full-64bit.exe>`_ (the last non-fastcomp version with Clang 3.2)
- `emsdk-1.12.0-full-32bit.exe <https://s3.amazonaws.com/mozilla-games/emscripten/releases/emsdk-1.12.0-full-32bit.exe>`_
- `emsdk-1.8.2-full-64bit.exe <https://s3.amazonaws.com/mozilla-games/emscripten/releases/emsdk-1.8.2-full-64bit.exe>`_
- `emsdk-1.8.2-full-32bit.exe <https://s3.amazonaws.com/mozilla-games/emscripten/releases/emsdk-1.8.2-full-32bit.exe>`_
- `emsdk-1.7.8-full-64bit.exe <https://s3.amazonaws.com/mozilla-games/emscripten/releases/emsdk-1.7.8-full-64bit.exe>`_
- `emsdk-1.7.8-full-32bit.exe <https://s3.amazonaws.com/mozilla-games/emscripten/releases/emsdk-1.7.8-full-32bit.exe>`_
- `emsdk-1.5.6.2-full-64bit.exe <https://s3.amazonaws.com/mozilla-games/emscripten/releases/emsdk-1.5.6.2-full-64bit.exe>`_
- `emsdk-1.5.6.2-full-32bit.exe <https://s3.amazonaws.com/mozilla-games/emscripten/releases/emsdk-1.5.6.2-full-32bit.exe>`_
- `emsdk-1.5.6.1-full.exe <https://s3.amazonaws.com/mozilla-games/emscripten/releases/emsdk-1.5.6.1-full.exe)>`_ (32-bit, first emsdk release)


A snapshot of all tagged releases (not SDKs) can be found at `emscripten/releases <https://github.com/kripken/emscripten/releases>`_.

