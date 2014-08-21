.. _Tutorial:

============================================
Emscripten Tutorial (under-construction)
============================================

**Using Emscripten is, at a base level, fairly simple. This tutorial takes you through the steps needed to compile your first Emscripten examples from the command line. It also shows how to preload files and set the compiler optimization flags.**

.. note:: We don't cover it in this tutorial, but Emscripten is also integrated with Microsoft Visual Studio 2010.

	The :term:`vs-tool` plugin is automatically deployed by the :term:`Windows NSIS Installer Emscripten SDK` if *Visual Studio 2010* is present on your system. This adds an 'Emscripten' configuration to the list of available Solution Configurations in Visual Studio. Activate this configuration for a solution/project to make Visual Studio run the project build through Emscripten, producing **.html** or **.js** output depending on the configured project properties.

First things first
======================

Make sure you have :ref:`downloaded and installed <sdk-download-and-install>` Emscripten (the exact approach for doing this will depend your operating system: Windows, Mac or Linux).

Emscripten is accessed using the :ref:`emcc <emccdoc>`. This script invokes all the other tools needed to build your code, and can act as a drop-in replacement for a standard compiler like *gcc*. It is called on the command line using ``emcc`` or ``em++``

.. note:: On Mac OS X the tool is called using the slightly different syntax: ``./emcc`` or ``./em++`` (or even directly via Python: ``python emcc``). The remainder of this tutorial uses the Windows syntax (``emcc``).

For the next section you will need to open a command prompt:

- On Linux or Mac OS X, open a *Terminal*. 
- On Windows open the :ref:`Emscripten Command Prompt <emcmdprompt>`, a command prompt that has been pre-configured with the correct system paths and settings to point to the :term:`active <Active Tool/SDK>` Emscripten tools. To access this prompt, type **Emscripten** in the Windows 8 start screen, and then select the **Emscripten Command Prompt** option.

Navigate with the command prompt to the :term:`SDK root directory` for your target SDK. This is an SDK-version-specific folder below the :term:`emsdk root directory`, e.g.: **<Emsdk Root>\\emscripten\\1.20.0\\**.

.. warning:: Emscripten test code must be built from the "SDK Root" above (some of the code is dependent on file locations, and will build but not run if compiled from another location). 


Verifying Emscripten
=====================

If you haven't run Emscripten before, run it now with: ::

    emcc -v 

If the output contains warnings about missing tools, see :ref:`verifying-the-emscripten-environment` for debugging help. Otherwise continue to the next sections where we'll build some code.


Running Emscripten
======================================

You can now compile your first C++ file to JavaScript!

First, lets have a look at the file to be compiled: **hello_world.cpp**. This is the simplest test code in the SDK, and as you can see, all it does is print "hello, world!" to the console and then exit.

.. include:: ../../../../tests/hello_world.cpp
   :literal:
   


To build the JavaScript version of this code we simply specify the C++ file after *emcc*: ::

	emcc tests/hello_world.cpp


There should now be an **a.out.js** file in the current directory. Run it using :term:`node.js`:

::

    node a.out.js

This prints "hello, world!" to the console, as expected.

.. tip:: If an error occurs when calling *emcc*, run it with the ``-v`` option to print out a lot of useful debug information.




Generating HTML
======================================

Emscripten can also generate HTML for testing embedded JavaScript. To generate HTML, use the ``-o`` (output) command and specify an html file as the target file: ::

    emcc tests/hello_world.cpp -o hello.html

Open the web page in a web browser. As you can see, the framework defines a text area for displaying the output of the ``printf()`` calls in the native code.

The HTML isn't limited just to just displaying text. You can also use the SDL API to show a colored cube in a Canvas element (on browsers that support it). For an example, build the **hello_world_sdl.cpp** test code and then refresh the browser: ::

    emcc tests/hello_world_sdl.cpp -o hello.html

The source code for the second example is given below:

.. include:: ../../../../tests/hello_world_sdl.cpp
   :literal:
   

Using files
======================================

Your C/C++ code can access files using the normal libc API (stdio: ``fopen``, etc.). 

JavaScript is usually run in the sandboxed environment of a web browser, without direct access to the local filesystem. Emscripten simulates a file system which you can access from the compiled code using the normal libc API. Files that you want to access should be :ref:`preloaded <emcc-preload-file>` or :ref:`embedded <emcc-embed-file>` into the virtual file system. 

Preloading generates a virtual filesystem that corresponds to the filesystem structure at *compile* time, relative to the current directory. 
	
.. todo:: **HamishW** When filesystem guide updated may be a better link for preloading and embedding than the emcc links above. These might even be better as term links in glossary.

The `hello_world_file.cpp <https://github.com/kripken/emscripten/blob/master/tests/hello_world.cpp>`_ example shows how to load a file (both the test code and the file to be loaded shown below):

.. include:: ../../../../tests/hello_world_file.cpp
   :literal:
   
.. include:: ../../../../tests/hello_world_file.txt
   :literal:

.. note:: The code loads a file at `tests/hello_world_file.txt <https://github.com/kripken/emscripten/blob/master/tests/hello_world_file.txt>`_. We compile the example from the directory "above" **tests** to ensure that the text file is stored at this location in the virtual filesystem.
   
The following command is used to preload the data file. The ``--preload-file`` option will automatically preload the file before running the compiled code. This is useful because loading data from the network cannot be done synchronously in browsers outside Web Workers. ::

    emcc tests/hello_world_file.cpp -o hello.html --preload-file tests/hello_world_file.txt
	

Open ``hello.html`` in the *Firefox web browser* to see the data from **hello_world_file.txt** being displayed. 

.. note:: Unfortunately *Chrome* and *Internet Explorer* do not support ``file://`` :term:`XHR` requests, and can't directly load the local file in which preloaded data is stored. For these browsers you'll need to serve the files using a webserver. The easiest way to do this is to use the python **SimpleHTTPServer** (in the current directory do ``python -m SimpleHTTPServer 8080`` and then open ``localhost:8080/hello.html``).

----

For an example of how to load files with SDL, check out `tests/hello_image_sdl.c <https://github.com/kripken/emscripten/blob/master/tests/hello_image_sdl.c>`_:

.. include:: ../../../../tests/hello_image_sdl.c
   :literal:

The source code expects a file **screenshot.jpg** in the current directory. As discussed above, this means that we need to compile the source and preload from the same directory that contains the screenshot. Change to the **tests/** directory and run: ::

    emcc hello_image_sdl.c --preload-file screenshot.jpg -o a.html

Then browse to **a.html** (again, noting that you will need to use either Mozilla Firefox or a web server). You should see a pretty cool image displayed.

For more information about working with the file system see the :ref:`Filesystem-Guide`, :ref:`Filesystem-API` and :ref:`Synchronous-virtual-XHR-backed-file-system-usage`.


Optimizing code
======================================

Emscripten, like *gcc*, generates unoptimized code by default. You can generate slightly-optimized code with the ``-O1`` command line argument (run the test code from the :term:`SDK root directory`): ::

    emcc -O1 tests/hello_world.cpp

The "hello world" code created in **a.out.js** doesn't really need to be optimized, so you won't see a difference in speed when compared to the unoptimized version. 

However, you can compare the generated code to see the differences. ``-O1`` applies several minor optimizations and removes some runtime assertions. For example, ``printf`` will have been replaced by ``puts`` in the generated code.

The optimizations provided by ``-O2`` are much more aggressive. If you run the following command and inspect the generated code (**a.out.js**) you will see that it looks very different: ::

    emcc -O2 tests/hello_world.cpp

For more information about compiler optimization options see :ref:`Optimizing-Code` and the :ref:`emcc tool reference <emcc-compiler-optimization-options>`.


.. _running-emscripten-tests:

Running the Emscripten Test Suite and Benchmarks
============================================================================

Emscripten has an extensive test suite at `tests/runner.py <https://github.com/kripken/emscripten/blob/master/tests/runner.py>`_. To run every test (this may take several hours), simply call the test script: ::

    python tests/runner.py

The individual tests are listed in the different test suites - for example "test_hello_world" is defined in the `core test suite here <https://github.com/kripken/emscripten/blob/master/tests/test_core.py#L12>`_. You can run individual tests as shown: ::

    python tests/runner.py test_hello_world

.. todo:: **HamishW** Confirm that this is how test suites are done. We really should have a stand alone topic for this and link to it at this point.

To view the generated code from that individual test, you can first set ``EMCC_DEBUG=1``. This is shown for both Windows and Linxu below: ::

	# On Windows, use "set" to set and un-set the environment variable:
	set EMCC_DEBUG=1 
	python tests/runner.py test_hello_world
	set EMCC_DEBUG=0
	
	# On Linux, you can do this all in one line
	EMCC_DEBUG=1 python tests/runner.py test_hello_world
	
The generated code is copied into the the temp directory (**TEMP_DIR/emscripten_temp**, where ``TEMP_DIR`` is defined in :ref:`~/.emscripten <compiler-configuration-file>`. By default the temporary directory location is **/tmp**). 

.. note:: You can use ``EMCC_DEBUG`` with :ref:`emcc <emccdoc>` as well (not just with the test runner). This tells *emcc* to save the internal code generation stages (much like ``emcc -v``).

You can also specify ``EM_SAVE_DIR=1`` in the environment (this is a test suite specific feature) to save the temporary directory that the test runner users to the same place as mentioned in the previous paragraph. This is useful if the test being run creates temporary files.

Note that **Node.js** cannot run all of the tests in the suite; if you care about running them all, you should get a recent trunk version of the `SpiderMonkey <https://developer.mozilla.org/en-US/docs/Mozilla/Projects/SpiderMonkey/Introduction_to_the_JavaScript_shell>`_ shell.


----

.. _running-emscripten-benchmarks:

To run the Emscripten benchmark tests, enter the following command: ::

    python tests/runner.py benchmark

This will compile a sequence of benchmarks and run them several times, reporting averaged statistics including a comparison to how fast the same code runs when compiled to a native executable.



General tips and next steps
======================================

This tutorial walked you through your first steps in calling Emscripten from the command line. There is, of course, far more you can do with the tool. Below are other general tips for using Emscripten:

-  This site has lots more information about :ref:`compiling and building projects <compiling-and-running-projects-index>`, :ref:`integrating your native code with the web environment <integrating-porting-index>`, :ref:`packaging your code <packaging-code-index>` and publishing.
-  The Emscripten test suite is a great place to look for examples of how to use Emscripten. For example, if you want to better understand how the *emcc* ``--pre-js`` option works, search for ``--pre-js`` in the test suite: the test suite is extensive and there are likely to be at least some examples.
-  To learn how to use Emscripten in advanced ways, read :ref:`src/settings.js <settings-js>` and :ref:`emcc <emccdoc>` which describe the compiler options, and :ref:`emscripten-h` which describes JavaScript-specific C APIs that your C/C++ programs can use when compiled with Emscripten.
-  When in doubt, :ref:`get in touch <contact>`!
