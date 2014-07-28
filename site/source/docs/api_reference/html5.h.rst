============================
html5.h (ready-for-review) 
============================

This page documents the C++ APIs provided by `html5.h <https://github.com/kripken/emscripten/blob/master/system/include/emscripten/html5.h>`_.

These APIs define the Emscripten low-level glue bindings for interfacing with the following HTML5 APIs:

	- `DOM Level 3 Events: Keyboard, Mouse, Mouse Wheel, Resize, Scroll, Focus <https://dvcs.w3.org/hg/dom3events/raw-file/tip/html/DOM3-Events.html>`_.
	- `Device Orientation Events for gyro and accelerometer <http://www.w3.org/TR/orientation-event/>`_.
	- `Screen Orientation Events for portrait/landscape handling <https://dvcs.w3.org/hg/screen-orientation/raw-file/tip/Overview.html>`_.
	- `Fullscreen Events for browser canvas fullscreen modes transitioning <https://dvcs.w3.org/hg/fullscreen/raw-file/tip/Overview.html>`_.
	- `Pointer Lock Events for relative-mode mouse motion control <http://www.w3.org/TR/pointerlock/>`_.
	- `Vibration API for mobile device haptic vibration feedback control <http://dev.w3.org/2009/dap/vibration/>`_.
	- `Page Visibility Events for power management control <http://www.w3.org/TR/page-visibility/>`_.
	- `Touch Events <http://www.w3.org/TR/touch-events/>`_.
	- `Gamepad API <http://www.w3.org/TR/gamepad/>`_.
	- `Beforeunload event <http://www.whatwg.org/specs/web-apps/current-work/multipage/history.html#beforeunloadevent>`_.
	- `WebGL context events <http://www.khronos.org/registry/webgl/specs/latest/1.0/#5.15.2>`_



.. contents:: Table of Contents
    :local:
    :depth: 1
	
How to use this API
===================
	
Most web APIs are event-based; functionality is accessed by registering a callback function that will be called when the event occurs. 

.. note:: The Gamepad API is currently an exception, as only a polling API is available. For some APIs, both an event-based and a polling-based API are exposed.


Registration functions
----------------------

The typical format of registration functions is as follows (some methods may omit some parameters): ::

	EMSCRIPTEN_RESULT emscripten_set_some_callback(
		const char *target, 	// Target HTML element id.
		void *userData,		// User-defined data to be passed to the callback.
		EM_BOOL useCapture, 	// Whether or not to use capture.
		em_someevent_callback_func callback 	// Callback function.
	);


.. _target-parameter-html5-api:	
	
The ``target`` parameter is the HTML Element ID to which the callback registration is to be applied. This field has the following special meanings:

	- ``0`` or ``NULL``: A default element is chosen automatically based on the event type, which should be reasonable most of the time.
	- ``#window``: The event listener is applied to the JavaScript 'window' object.
	- ``#document``: The event listener is applied to the JavaScript 'document' object.
	- ``#screen``: The event listener is applied to the JavaScript 'window.screen' object.
	- ``#canvas``: The event listener is applied to the Emscripten default WebGL canvas element.
	- Any other string without a leading hash "#" sign: The event listener is applied to the element by the given ID on the page.

.. _userdata-parameter-html5-api:	
	
The ``userData`` parameter is a user-defined value that is passed (unchanged) to the registered event callback. This can be used to, for example, pass a pointer to a C++ class or similarly to enclose the C API in a clean object-oriented manner.

.. _usecapture-parameter-html5-api:	

The ``useCapture`` parameter  maps to ``useCapture`` in `EventTarget.addEventListener <https://developer.mozilla.org/en-US/docs/Web/API/EventTarget.addEventListener>`_. It indicates whether or not to initiate *capture*: if ``true`` the callback will be invoked only for the DOM capture and target phases, if ``false`` the callback will be triggered during the target and bubbling phases. See `EventTarget.addEventListener <https://developer.mozilla.org/en-US/docs/Web/API/EventTarget.addEventListener>`_ and `DOM Level 3 Events <http://www.w3.org/TR/2003/NOTE-DOM-Level-3-Events-20031107/events.html#Events-phases>`_ for a more detailed explanation.

Most functions return the result using the type :c:data:`EMSCRIPTEN_RESULT`. Nonzero and positive values denote success. Negative values signal failure. None of the functions fail or abort by throwing a JavaScript or C++ exception. If a particular browser does not support the given feature, the value :c:data:`EMSCRIPTEN_RESULT_NOT_SUPPORTED` will be returned at the time the callback is registered.

	
Callback functions
------------------

When the event occurs the callback is invoked with the relevant event "type" (for example :c:data:`EMSCRIPTEN_EVENT_CLICK`), a ``struct`` containing the details of the event that occurred, and the ``userData`` that was originally passed to the registration function. The general format of the callback function is: ::

	typedef EM_BOOL (*em_someevent_callback_func) // Callback function. Return true if event is "consumed".
		(
		int eventType, // The type of event.
		const EmscriptenSomeEvent *keyEvent, // Information about the event.
		void *userData // User data passed from the registration function.
		);


.. _callback-handler-return-em_bool-html5-api:	

Callback handlers that return an :c:data:`EM_BOOL` may specify ``true`` to signal that the handler *consumed* the event (this suppresses the default action for that event by calling its ``.preventDefault();`` member). Returning ``false`` indicates that the event was not consumed - the default browser event action is carried out and the event is allowed to pass on/bubble up as normal.

Calling a registration function with a ``null`` pointer for the callback causes a de-registration of that callback from the given ``target`` element. All event handlers are also automatically unregistered when the C ``exit()`` function is invoked during the ``atexit`` handler pass. Use either the function :c:func:`emscripten_set_main_loop` or set ``Module.noExitRuntime = true;`` to make sure that leaving ``main()`` will not immediately cause an ``exit()`` and clean up the event handlers.

.. _web-security-functions-html5-api:	

Functions affected by web security
----------------------------------

Some functions, including :c:func:`emscripten_request_pointerlock` and :c:func:`emscripten_request_fullscreen`, are affected by web security.

While the functions can be called anywhere, the actual "requests" can only be raised inside the handler for a user-generated event (for example a key, mouse or touch press/release). 

When porting code, it may be difficult to ensure that the functions are called inside appropriate event handlers (so that the requests are raised immediately). As a convenience, developers can set ``deferUntilInEventHandler=true`` to automatically defer insecure requests until the user next presses a keyboard or mouse button. This simplifies porting, but often results in a poorer user experience. For example, the user must click once on the canvas to hide the pointer or transition to full screen.

Where possible, the functions should only be called inside appropriate event handlers. Setting ``deferUntilInEventHandler=false`` causes the functions to abort with an error if the request is refused due to a security restriction: this is a useful mechanism for discovering instances where the functions are called outside the handler for a user-generated event.


General types
=============


.. c:macro:: EM_BOOL

	This is the Emscripten type for a ``bool``.  
	
	
.. c:macro:: EM_UTF8

	This is the Emscripten type for a UTF8 string (maps to an ``char``). This is used for node names, element ids, etc.

	

Function result values
======================

Most functions in this API return a result of type :c:data:`EMSCRIPTEN_RESULT`. None of the functions fail or abort by throwing a JavaScript or C++ exception. If a particular browser does not support the given feature, the value :c:data:`EMSCRIPTEN_RESULT_NOT_SUPPORTED` will be returned at the time the callback is registered.

	
.. c:macro:: EMSCRIPTEN_RESULT

	This type is used to return the result of most functions in this API.  Positive values denote success, while zero and negative values signal failure. Possible values are listed below.
	
	
.. c:macro:: EMSCRIPTEN_RESULT_SUCCESS

	The operation succeeded

.. c:macro:: EMSCRIPTEN_RESULT_DEFERRED

	The requested operation cannot be completed now for :ref:`web security reasons<web-security-functions-html5-api>`. It was deferred for completion in the next event handler.
	
.. c:macro:: EMSCRIPTEN_RESULT_NOT_SUPPORTED

	The given operation is not supported by this browser or the target element.	This value will be returned at the time the callback is registered if the operation is not supported.
	

.. c:macro:: EMSCRIPTEN_RESULT_FAILED_NOT_DEFERRED

	The requested operation could not be completed now for :ref:`web security reasons<web-security-functions-html5-api>`. It failed because the user requested the operation not be deferred.	

.. c:macro:: EMSCRIPTEN_RESULT_INVALID_TARGET

	The operation failed because the specified target element is invalid.	

.. c:macro:: EMSCRIPTEN_RESULT_UNKNOWN_TARGET

	The operation failed because the specified target element was not found.	

.. c:macro:: EMSCRIPTEN_RESULT_INVALID_PARAM

	The operation failed because an invalid parameter was passed to the function.	

.. c:macro:: EMSCRIPTEN_RESULT_FAILED

	The operation failed for some generic reason.	

.. c:macro:: EMSCRIPTEN_RESULT_NO_DATA

	The operation failed because no data is currently available.	
	


Keys
====

Defines
------- 

.. c:macro:: EMSCRIPTEN_EVENT_KEYPRESS
	EMSCRIPTEN_EVENT_KEYDOWN
	EMSCRIPTEN_EVENT_KEYUP
			 
    Emscripten key events.
	
.. c:macro:: DOM_KEY_LOCATION

	The location of the key on the keyboard; one of the :c:data:`DOM_KEY_LOCATION_XXX values <DOM_KEY_LOCATION_STANDARD>`.	

.. c:macro:: DOM_KEY_LOCATION_STANDARD
	DOM_KEY_LOCATION_LEFT
	DOM_KEY_LOCATION_RIGHT	
	DOM_KEY_LOCATION_NUMPAD	

	Locations of the key on the keyboard.

Struct
------ 

.. c:type:: EmscriptenKeyboardEvent

	The event structure passed in `keyboard events <https://dvcs.w3.org/hg/dom3events/raw-file/tip/html/DOM3-Events.html#keys>`_: ``keypress``, ``keydown`` and ``keyup``.

	Note that since the `DOM Level 3 Events spec <https://dvcs.w3.org/hg/dom3events/raw-file/tip/html/DOM3-Events.html#keys>`_ is very recent at the time of writing (2014-03), uniform support for the different fields in the spec is still in flux. Be sure to check the results in multiple browsers. See the `unmerged pull request #2222 <https://github.com/kripken/emscripten/pull/2222>`_ for an example of how to interpret the legacy key events.


	.. c:member:: EM_UTF8 key
	
		The printed representation of the pressed key. 
		
		Maximum size 32 ``char`` (i.e. ``EM_UTF8 key[32]``).

	.. c:member:: EM_UTF8 code
	
		A string that identifies the physical key being pressed. The value is not affected by the current keyboard layout or modifier state, so a particular key will always return the same value. 
		
		Maximum size 32 ``char`` (i.e. ``EM_UTF8 code[32]``).				
		
	.. c:member:: unsigned long location
	
		Indicates the location of the key on the keyboard. One of the :c:data:`DOM_KEY_LOCATION <DOM_KEY_LOCATION_STANDARD>` values.

	.. c:member:: EM_BOOL ctrlKey
		EM_BOOL shiftKey
		EM_BOOL altKey
		EM_BOOL metaKey
	
		Specifies which modifiers were active during the key event.	

	.. c:member:: EM_BOOL repeat
	
		Specifies if this keyboard event represents a repeated press.

	.. c:member:: EM_UTF8 locale
	
		A locale string indicating the configured keyboard locale. This may be the empty string if the browser or device doesn't know the keyboard's locale. 
		
		Maximum size 32 char (i.e. ``EM_UTF8 locale[32]``).
  		
	.. c:member:: EM_UTF8 charValue
	
		The following fields are values from previous versions of the DOM key events specifications. See `the character representation of the key <https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent?redirectlocale=en-US&redirectslug=DOM%2FKeyboardEvent>`_. This is the field ``char`` from the docs, but renamed to ``charValue`` to avoid a C reserved word. 
		
		Maximum size 32 ``char`` (i.e. ``EM_UTF8 charValue[32]``).
		
		.. warning:: This attribute has been dropped from DOM Level 3 events.

	.. c:member:: unsigned long charCode
	
		The Unicode reference number of the key; this attribute is used only by the keypress event. For keys whose char attribute contains multiple characters, this is the Unicode value of the first character in that attribute.
		
		.. warning:: This attribute is deprecated, you should use the field ``key`` instead, if available.
		
	.. c:member:: unsigned long keyCode
	
		A system and implementation dependent numerical code identifying the unmodified value of the pressed key.
		
		.. warning:: This attribute is deprecated, you should use the field ``key`` instead, if available.
		
		
	.. c:member:: unsigned long which
	
		A system and implementation dependent numeric code identifying the unmodified value of the pressed key; this is usually the same as ``keyCode``.
		
		.. warning:: This attribute is deprecated, you should use the field ``key`` instead, if available.

		
Callback functions
------------------

.. c:type:: em_key_callback_func

	Function pointer for the :c:func:`keypress callback functions <emscripten_set_keypress_callback>`.

	Defined as: :: 

		typedef EM_BOOL (*em_key_callback_func)(int eventType, const EmscriptenKeyboardEvent *keyEvent, void *userData);
	
	:param int eventType: The type of :c:data:`key event <EMSCRIPTEN_EVENT_KEYPRESS>`.
	:param keyEvent: Information about the key event that occurred.
	:type keyEvent: const EmscriptenKeyboardEvent*
	:param void* userData: The ``userData`` originally passed to the registration function.
	:returns: |callback-handler-return-value-doc|
	:rtype: |EM_BOOL|
		
		
Functions
--------- 

.. c:function:: EMSCRIPTEN_RESULT emscripten_set_keypress_callback(const char *target, void *userData, EM_BOOL useCapture, em_key_callback_func callback)
	EMSCRIPTEN_RESULT emscripten_set_keydown_callback(const char *target, void *userData, EM_BOOL useCapture, em_key_callback_func callback)
	EMSCRIPTEN_RESULT emscripten_set_keyup_callback(const char *target, void *userData, EM_BOOL useCapture, em_key_callback_func callback)
		
	Registers a callback function for receiving browser-generated keyboard input events. 
	
	:param target: |target-parameter-doc|
	:type target: const char*
	:param void* userData: |userData-parameter-doc|
	:param EM_BOOL  useCapture: |useCapture-parameter-doc|
	:param em_key_callback_func callback: |callback-function-parameter-doc|	
	:returns: :c:data:`EMSCRIPTEN_RESULT_SUCCESS`, or one of the other result values.
	:rtype: |EMSCRIPTEN_RESULT|

	:seealso: 
		- https://developer.mozilla.org/en/DOM/Event/UIEvent/KeyEvent 
		- http://www.javascriptkit.com/jsref/eventkeyboardmouse.shtml

Mouse
=====

Defines
-------

.. c:macro:: EMSCRIPTEN_EVENT_CLICK
	EMSCRIPTEN_EVENT_MOUSEDOWN
	EMSCRIPTEN_EVENT_MOUSEUP
	EMSCRIPTEN_EVENT_DBLCLICK
	EMSCRIPTEN_EVENT_MOUSEMOVE
			 
    Emscripten mouse events.


Struct
------ 	

.. c:type:: EmscriptenMouseEvent

	The event structure passed in `mouse events <https://dvcs.w3.org/hg/dom3events/raw-file/tip/html/DOM3-Events.html#interface-MouseEvent>`_: `click <https://dvcs.w3.org/hg/dom3events/raw-file/tip/html/DOM3-Events.html#event-type-click>`_, `mousedown <https://dvcs.w3.org/hg/dom3events/raw-file/tip/html/DOM3-Events.html#event-type-mousedown>`_, `mouseup <https://dvcs.w3.org/hg/dom3events/raw-file/tip/html/DOM3-Events.html#event-type-mouseup>`_, `dblclick <https://dvcs.w3.org/hg/dom3events/raw-file/tip/html/DOM3-Events.html#event-type-dblclick>`_ and `mousemove <https://dvcs.w3.org/hg/dom3events/raw-file/tip/html/DOM3-Events.html#event-type-mousemove>`_.
	

	.. c:member:: double timestamp;
	
		A timestamp of when this data was generated by the browser. This is an absolute wallclock time in milliseconds.

	.. c:member:: long screenX
		long screenY
	
		The coordinates relative to the browser screen coordinate system.
		
	.. c:member:: long clientX
		long clientY
	
		The coordinates relative to the viewport associate with the event.
  
		
	.. c:member:: EM_BOOL ctrlKey
		EM_BOOL shiftKey
		EM_BOOL altKey
		EM_BOOL metaKey
	
		Specifies which modifiers were active during the mouse event.
		
		
	.. c:member:: unsigned short button
	
		Identifies which pointer device button changed state (see `MouseEvent.button <https://developer.mozilla.org/en-US/docs/Web/API/MouseEvent.button>`_):

			- 0 : Left button
			- 1 : Middle button (if present)
			- 2 : Right button

		
	.. c:member:: unsigned short buttons
	
		A bitmask that indicates which combinations of mouse buttons were being held down at the time of the event.
  
	.. c:member:: long movementX
		long movementY;
	
		If pointer lock is active, these two extra fields give relative mouse movement since the last event.
  
		
	.. c:member:: long canvasX
		 long canvasY
	
		These fields give the mouse coordinates mapped to the Emscripten canvas client area (Emscripten-specific extension).


	.. c:member:: long padding
	
		Internal, and can be ignored (note for implementers: pad this struct to multiple of 8 bytes to make WheelEvent unambiguously align to 8 bytes). 


Callback functions
------------------

.. c:type:: em_mouse_callback_func

	Function pointer for the :c:func:`mouse event callback functions <emscripten_set_click_callback>`.

	Defined as: :: 

		typedef EM_BOOL (*em_mouse_callback_func)(int eventType, const EmscriptenMouseEvent *keyEvent, void *userData);
	
	:param int eventType: The type of :c:data:`mouse event <EMSCRIPTEN_EVENT_CLICK>`.
	:param keyEvent: Information about the mouse event that occurred.
	:type keyEvent: const EmscriptenMouseEvent*
	:param void* userData: The ``userData`` originally passed to the registration function.
	:returns: |callback-handler-return-value-doc|
	:rtype: |EM_BOOL|


		
Functions
--------- 

.. c:function:: EMSCRIPTEN_RESULT emscripten_set_click_callback(const char *target, void *userData, EM_BOOL useCapture, em_mouse_callback_func callback)
	EMSCRIPTEN_RESULT emscripten_set_mousedown_callback(const char *target, void *userData, EM_BOOL useCapture, em_mouse_callback_func callback)
	EMSCRIPTEN_RESULT emscripten_set_mouseup_callback(const char *target, void *userData, EM_BOOL useCapture, em_mouse_callback_func callback)
	EMSCRIPTEN_RESULT emscripten_set_dblclick_callback(const char *target, void *userData, EM_BOOL useCapture, em_mouse_callback_func callback)
	EMSCRIPTEN_RESULT emscripten_set_mousemove_callback(const char *target, void *userData, EM_BOOL useCapture, em_mouse_callback_func callback)

	Registers a callback function for receiving browser-generated `mouse input events <https://developer.mozilla.org/en/DOM/MouseEvent>`_.

	:param target: |target-parameter-doc|
	:type target: const char*
	:param void* userData: |userData-parameter-doc|
	:param EM_BOOL useCapture: |useCapture-parameter-doc|
	:param em_mouse_callback_func callback: |callback-function-parameter-doc|
	:returns: :c:data:`EMSCRIPTEN_RESULT_SUCCESS`, or one of the other result values.
	:rtype: |EMSCRIPTEN_RESULT|
	

		
.. c:function:: EMSCRIPTEN_RESULT emscripten_get_mouse_status(EmscriptenMouseEvent *mouseState)

	Returns the most recently received mouse event state. 
	
	Note that for this function call to succeed, :c:func:`emscripten_set_xxx_callback <emscripten_set_click_callback>` must have first been called with one of the mouse event types and a non-zero callback function pointer to enable the Mouse state capture.

	:param EmscriptenMouseEvent* mouseState: The most recently received mouse event state.
	:returns: :c:data:`EMSCRIPTEN_RESULT_SUCCESS`, or one of the other result values.
	:rtype: |EMSCRIPTEN_RESULT|
	


Wheel
=====

Defines
-------

.. c:macro:: EMSCRIPTEN_EVENT_WHEEL
			 
    Emscripten wheel event.
	
.. c:macro:: DOM_DELTA_PIXEL

	The units of measurement for the delta must be pixels (from `spec <http://www.w3.org/TR/DOM-Level-3-Events/#constants-1)>`_).
	
.. c:macro:: DOM_DELTA_LINE

	The units of measurement for the delta must be individual lines of text (from `spec <http://www.w3.org/TR/DOM-Level-3-Events/#constants-1)>`_).
	
.. c:macro:: DOM_DELTA_PAGE

	The units of measurement for the delta must be pages, either defined as a single screen or as a demarcated page (from `spec <http://www.w3.org/TR/DOM-Level-3-Events/#constants-1)>`_).

	
Struct
------ 

.. c:type:: EmscriptenWheelEvent

	The event structure passed in `mousewheel events <http://www.w3.org/TR/DOM-Level-3-Events/#event-type-wheel>`_.
	
	.. c:member:: EmscriptenMouseEvent mouse
	
		Specifies general mouse information related to this event.
  
	.. c:member:: double deltaX
		double deltaY
		double deltaZ
	
		Movement of the wheel on each of the axis.
		
	.. c:member:: unsigned long deltaMode
	
		One of the :c:data:`DOM_DELTA_<DOM_DELTA_PIXEL>` values that indicates the units of measurement for the delta values.


Callback functions
------------------

.. c:type:: em_wheel_callback_func

	Function pointer for the :c:func:`wheel event callback functions <emscripten_set_wheel_callback>`.

	Defined as: :: 

		typedef EM_BOOL (*em_wheel_callback_func)(int eventType, const EmscriptenWheelEvent *keyEvent, void *userData);
	
	:param int eventType: The type of wheel event (:c:data:`EMSCRIPTEN_EVENT_WHEEL`).
	:param keyEvent: Information about the wheel event that occurred.
	:type keyEvent: const EmscriptenWheelEvent*
	:param void* userData: The ``userData`` originally passed to the registration function.
	:returns: |callback-handler-return-value-doc|
	:rtype: |EM_BOOL|

	
		
Functions
--------- 
		
.. c:function:: EMSCRIPTEN_RESULT EMSCRIPTEN_RESULT emscripten_set_wheel_callback(const char *target, void *userData, EM_BOOL useCapture, em_wheel_callback_func callback)
	  	
	Registers a callback function for receiving browser-generated `mousewheel events <http://www.w3.org/TR/DOM-Level-3-Events/#event-type-wheel>`_.

	:param target: |target-parameter-doc|
	:type target: const char*
	:param void* userData: |userData-parameter-doc|
	:param EM_BOOL useCapture: |useCapture-parameter-doc|
	:param em_wheel_callback_func callback: |callback-function-parameter-doc|
	:returns: :c:data:`EMSCRIPTEN_RESULT_SUCCESS`, or one of the other result values.
	:rtype: |EMSCRIPTEN_RESULT|



UI
==

Defines
-------

.. c:macro:: EMSCRIPTEN_EVENT_RESIZE
	EMSCRIPTEN_EVENT_SCROLL
			 
    Emscripten UI events.
	

Struct
------ 

.. c:type:: EmscriptenUiEvent

	The event structure passed in DOM element `UIEvent <https://dvcs.w3.org/hg/dom3events/raw-file/tip/html/DOM3-Events.html#interface-UIEvent>`_ events: `resize <https://dvcs.w3.org/hg/dom3events/raw-file/tip/html/DOM3-Events.html#event-type-resize>`_ and `scroll <https://dvcs.w3.org/hg/dom3events/raw-file/tip/html/DOM3-Events.html#event-type-scroll>`_.

	
	.. c:member:: long detail
	
		Specifies additional detail/information about this event.

	.. c:member:: int documentBodyClientWidth
		int documentBodyClientHeight
	
		The clientWidth/clientHeight of the document.body element.
		
	.. c:member:: int windowInnerWidth
		int windowInnerHeight
	
		The innerWidth/innerHeight of the window element.

	.. c:member:: int windowOuterWidth
		int windowOuterHeight;
	
		The outerWidth/outerHeight of the window element.
  
	.. c:member:: int scrollTop
		int scrollLeft
	
		The page scroll position.


Callback functions
------------------

.. c:type:: em_ui_callback_func

	Function pointer for the :c:func:`UI event callback functions <emscripten_set_resize_callback>`.

	Defined as: :: 

		typedef EM_BOOL (*em_ui_callback_func)(int eventType, const EmscriptenUiEvent *keyEvent, void *userData);
	
	:param int eventType: The type of UI event (:c:data:`EMSCRIPTEN_EVENT_RESIZE`).
	:param keyEvent: Information about the UI event that occurred.
	:type keyEvent: const EmscriptenUiEvent*
	:param void* userData: The ``userData`` originally passed to the registration function.
	:returns: |callback-handler-return-value-doc|
	:rtype: |EM_BOOL|
		
		
Functions
--------- 

.. c:function:: EMSCRIPTEN_RESULT emscripten_set_resize_callback(const char *target, void *userData, EM_BOOL useCapture, em_ui_callback_func callback)
	EMSCRIPTEN_RESULT emscripten_set_scroll_callback(const char *target, void *userData, EM_BOOL useCapture, em_ui_callback_func callback)
		
	Registers a callback function for receiving DOM element `resize <https://dvcs.w3.org/hg/dom3events/raw-file/tip/html/DOM3-Events.html#event-type-resize>`_ and `scroll <https://dvcs.w3.org/hg/dom3events/raw-file/tip/html/DOM3-Events.html#event-type-scroll>`_ events.

	:param target: |target-parameter-doc|
	:type target: const char*
	:param void* userData: |userData-parameter-doc|
	:param EM_BOOL useCapture: |useCapture-parameter-doc|
	:param em_ui_callback_func callback: |callback-function-parameter-doc|
	:returns: :c:data:`EMSCRIPTEN_RESULT_SUCCESS`, or one of the other result values.
	:rtype: |EMSCRIPTEN_RESULT|


	

Focus
=====

Defines
-------

.. c:macro:: EMSCRIPTEN_EVENT_BLUR
	EMSCRIPTEN_EVENT_FOCUS
	EMSCRIPTEN_EVENT_FOCUSIN
	EMSCRIPTEN_EVENT_FOCUSOUT
			 
    Emscripten focus events.
	

Struct
------ 

.. c:type:: EmscriptenFocusEvent

	The event structure passed in DOM element `blur <https://dvcs.w3.org/hg/dom3events/raw-file/tip/html/DOM3-Events.html#event-type-blur>`_, `focus <https://dvcs.w3.org/hg/dom3events/raw-file/tip/html/DOM3-Events.html#event-type-focus>`_, `focusin <https://dvcs.w3.org/hg/dom3events/raw-file/tip/html/DOM3-Events.html#event-type-focusin>`_ and `focusout <https://dvcs.w3.org/hg/dom3events/raw-file/tip/html/DOM3-Events.html#event-type-focusout>`_ events.
	
	.. c:member:: EM_UTF8 nodeName
	
		The `nodeName <https://developer.mozilla.org/en-US/docs/Web/API/Node.nodeName>`_ of the target HTML Element. 
		
		Maximum size 128 ``char`` (i.e. ``EM_UTF8 nodeName[128]``).

	.. c:member:: EM_UTF8 id
	
		The HTML Element ID of the target element. 
		
		Maximum size 128 ``char`` (i.e. ``EM_UTF8 id[128]``).
	

	
Callback functions
------------------

.. c:type:: em_focus_callback_func

	Function pointer for the :c:func:`focus event callback functions <emscripten_set_blur_callback>`.

	Defined as: :: 

		typedef EM_BOOL (*em_focus_callback_func)(int eventType, const EmscriptenFocusEvent *keyEvent, void *userData);
	
	:param int eventType: The type of focus event (:c:data:`EMSCRIPTEN_EVENT_BLUR`).
	:param keyEvent: Information about the focus event that occurred.
	:type keyEvent: const EmscriptenFocusEvent*
	:param void* userData: The ``userData`` originally passed to the registration function.
	:returns: |callback-handler-return-value-doc|
	:rtype: |EM_BOOL|

			
		
Functions
--------- 

.. c:function:: EMSCRIPTEN_RESULT emscripten_set_blur_callback(const char *target, void *userData, EM_BOOL useCapture, em_focus_callback_func callback)
	EMSCRIPTEN_RESULT emscripten_set_focus_callback(const char *target, void *userData, EM_BOOL useCapture, em_focus_callback_func callback)
	EMSCRIPTEN_RESULT emscripten_set_focusin_callback(const char *target, void *userData, EM_BOOL useCapture, em_focus_callback_func callback)
	EMSCRIPTEN_RESULT emscripten_set_focusout_callback(const char *target, void *userData, EM_BOOL useCapture, em_focus_callback_func callback)
		
	Registers a callback function for receiving DOM element `blur <https://dvcs.w3.org/hg/dom3events/raw-file/tip/html/DOM3-Events.html#event-type-blur>`_, `focus <https://dvcs.w3.org/hg/dom3events/raw-file/tip/html/DOM3-Events.html#event-type-focus>`_, `focusin <https://dvcs.w3.org/hg/dom3events/raw-file/tip/html/DOM3-Events.html#event-type-focusin>`_ and `focusout <https://dvcs.w3.org/hg/dom3events/raw-file/tip/html/DOM3-Events.html#event-type-focusout>`_ events.

	:param target: |target-parameter-doc|
	:type target: const char*
	:param void* userData: |userData-parameter-doc|
	:param EM_BOOL useCapture: |useCapture-parameter-doc|
	:param em_focus_callback_func callback: |callback-function-parameter-doc|
	:returns: :c:data:`EMSCRIPTEN_RESULT_SUCCESS`, or one of the other result values.
	:rtype: |EMSCRIPTEN_RESULT|


		
Device orientation
==================

Defines
-------

.. c:macro:: EMSCRIPTEN_EVENT_DEVICEORIENTATION
			 
    Emscripten ``deviceorientation`` events.

Struct
------ 

.. c:type:: EmscriptenDeviceOrientationEvent

	The event structure passed in the `deviceorientation <http://dev.w3.org/geo/api/spec-source-orientation.html#deviceorientation>`_ event.
	
	
	.. c:member:: double timestamp
	
		Absolute wallclock time when the event occurred (in milliseconds).

	.. c:member:: double alpha
		double beta
		double gamma
	
		The orientation of the device in terms of the transformation from a coordinate frame fixed on the Earth to a coordinate frame fixed in the device. 
  
  
	.. c:member:: EM_BOOL absolute
	
		If ``false``, the orientation is only relative to some other base orientation, not to the fixed coordinate frame.


Callback functions
------------------

.. c:type:: em_deviceorientation_callback_func

	Function pointer for the :c:func:`orientation event callback functions <emscripten_set_deviceorientation_callback>`.

	Defined as: :: 

		typedef EM_BOOL (*em_deviceorientation_callback_func)(int eventType, const EmscriptenDeviceOrientationEvent *keyEvent, void *userData);
	
	:param int eventType: The type of orientation event (:c:data:`EMSCRIPTEN_EVENT_DEVICEORIENTATION`).
	:param keyEvent: Information about the orientation event that occurred.
	:type keyEvent: const EmscriptenDeviceOrientationEvent*
	:param void* userData: The ``userData`` originally passed to the registration function.
	:returns: |callback-handler-return-value-doc|
	:rtype: |EM_BOOL|

	
		
Functions
--------- 

.. c:function:: EMSCRIPTEN_RESULT emscripten_set_deviceorientation_callback(void *userData, EM_BOOL useCapture, em_deviceorientation_callback_func callback)
		
	Registers a callback function for receiving the `deviceorientation <http://dev.w3.org/geo/api/spec-source-orientation.html#deviceorientation>`_ event.

	:param void* userData: |userData-parameter-doc|
	:param EM_BOOL useCapture: |useCapture-parameter-doc|
	:param em_deviceorientation_callback_func callback: |callback-function-parameter-doc|
	:returns: :c:data:`EMSCRIPTEN_RESULT_SUCCESS`, or one of the other result values.
	:rtype: |EMSCRIPTEN_RESULT|


.. c:function:: EMSCRIPTEN_RESULT emscripten_get_deviceorientation_status(EmscriptenDeviceOrientationEvent *orientationState)

	Returns the most recently received ``deviceorientation`` event state. 
	
	Note that for this function call to succeed, :c:func:`emscripten_set_deviceorientation_callback` must have first been called with one of the mouse event types and a non-zero callback function pointer to enable the ``deviceorientation`` state capture.

	:param EmscriptenDeviceOrientationEvent *orientationState: The most recently received deviceorientation event state.
	:returns: :c:data:`EMSCRIPTEN_RESULT_SUCCESS`, or one of the other result values.
	:rtype: |EMSCRIPTEN_RESULT|

	

Device motion
=============

Defines
-------

.. c:macro:: EMSCRIPTEN_EVENT_DEVICEMOTION
			 
    Emscripten `devicemotion <http://w3c.github.io/deviceorientation/spec-source-orientation.html#devicemotion>`_ event.


Struct
------

.. c:type:: EmscriptenDeviceMotionEvent

	The event structure passed in the `devicemotion <http://w3c.github.io/deviceorientation/spec-source-orientation.html#devicemotion>`_ event.
	
	.. c:member:: double timestamp
	
		Absolute wallclock time when the event occurred (milliseconds).


	.. c:member:: double accelerationX
		double accelerationY
		double accelerationZ
	
		Acceleration of the device excluding gravity.

  
	.. c:member:: double accelerationIncludingGravityX
		double accelerationIncludingGravityY
		double accelerationIncludingGravityZ	

		Acceleration of the device including gravity.


	.. c:member:: double rotationRateAlpha
		double rotationRateBeta
		double rotationRateGamma
	
		The rotational delta of the device.
  

Callback functions
------------------

.. c:type:: em_devicemotion_callback_func

	Function pointer for the :c:func:`devicemotion event callback functions <emscripten_set_devicemotion_callback>`.

	Defined as: :: 

		typedef EM_BOOL (*em_devicemotion_callback_func)(int eventType, const EmscriptenDeviceMotionEvent *keyEvent, void *userData);
	
	:param int eventType: The type of devicemotion event (:c:data:`EMSCRIPTEN_EVENT_DEVICEMOTION`).
	:param keyEvent: Information about the devicemotion event that occurred.
	:type keyEvent: const EmscriptenDeviceMotionEvent*
	:param void* userData: The ``userData`` originally passed to the registration function.
	:returns: |callback-handler-return-value-doc|
	:rtype: |EM_BOOL|


		
  
Functions
--------- 
		
.. c:function:: EMSCRIPTEN_RESULT emscripten_set_devicemotion_callback(void *userData, EM_BOOL useCapture, em_devicemotion_callback_func callback)
		
	Registers a callback function for receiving the `devicemotion <http://w3c.github.io/deviceorientation/spec-source-orientation.html#devicemotion>`_ event.

	:param void* userData: |userData-parameter-doc|
	:param EM_BOOL useCapture: |useCapture-parameter-doc|
	:param em_devicemotion_callback_func callback: |callback-function-parameter-doc|
	:returns: :c:data:`EMSCRIPTEN_RESULT_SUCCESS`, or one of the other result values.
	:rtype: |EMSCRIPTEN_RESULT|


.. c:function:: EMSCRIPTEN_RESULT emscripten_get_devicemotion_status(EmscriptenDeviceMotionEvent *motionState)

	Returns the most recently received `devicemotion <http://w3c.github.io/deviceorientation/spec-source-orientation.html#devicemotion>`_ event state. 
	
	Note that for this function call to succeed, :c:func:`emscripten_set_devicemotion_callback` must have first been called with one of the mouse event types and a non-zero callback function pointer to enable the ``devicemotion`` state capture.

	:param EmscriptenDeviceMotionEvent *motionState: The most recently received ``devicemotion`` event state.
	:returns: :c:data:`EMSCRIPTEN_RESULT_SUCCESS`, or one of the other result values.
	:rtype: |EMSCRIPTEN_RESULT|

	

Orientation
===========

Defines
-------

.. c:macro:: EMSCRIPTEN_EVENT_ORIENTATIONCHANGE
			 
    Emscripten `orientationchange <https://w3c.github.io/screen-orientation/>`_ event.
	
	
.. c:macro:: EMSCRIPTEN_ORIENTATION_PORTRAIT_PRIMARY

	Primary portrait mode orientation.

.. c:macro:: EMSCRIPTEN_ORIENTATION_PORTRAIT_SECONDARY

	Secondary portrait mode orientation.
	
.. c:macro:: EMSCRIPTEN_ORIENTATION_LANDSCAPE_PRIMARY

	Primary landscape mode orientation.
	
.. c:macro:: EMSCRIPTEN_ORIENTATION_LANDSCAPE_SECONDARY

	Secondary landscape mode orientation.

	
Struct
------

.. c:type:: EmscriptenOrientationChangeEvent

	The event structure passed in the `orientationchange <https://w3c.github.io/screen-orientation/>`_ event. 
	
	
	.. c:member:: int orientationIndex
	
		One of the :c:type:`EM_ORIENTATION_PORTRAIT_xxx <EMSCRIPTEN_ORIENTATION_PORTRAIT_PRIMARY>` fields, or -1 if unknown.

	.. c:member:: int orientationAngle
	
		Emscripten-specific extension: Some browsers refer to 'window.orientation', so report that as well.
		
		Orientation angle in degrees. 0: "default orientation", i.e. default upright orientation to hold the mobile device in. Could be either landscape or portrait.
			

Callback functions
------------------

.. c:type:: em_orientationchange_callback_func

	Function pointer for the :c:func:`orientationchange event callback functions <emscripten_set_orientationchange_callback>`.

	Defined as: :: 

		typedef EM_BOOL (*em_orientationchange_callback_func)(int eventType, const EmscriptenOrientationChangeEvent *keyEvent, void *userData);
	
	:param int eventType: The type of orientationchange event (:c:data:`EMSCRIPTEN_EVENT_ORIENTATIONCHANGE`).
	:param keyEvent: Information about the orientationchange event that occurred.
	:type keyEvent: const EmscriptenOrientationChangeEvent*
	:param void* userData: The ``userData`` originally passed to the registration function.
	:returns: |callback-handler-return-value-doc|
	:rtype: |EM_BOOL|

		
Functions
--------- 

.. c:function:: EMSCRIPTEN_RESULT emscripten_set_orientationchange_callback(void *userData, EM_BOOL useCapture, em_orientationchange_callback_func callback)
		
	Registers a callback function for receiving the `orientationchange <https://w3c.github.io/screen-orientation/>`_ event.

	:param void* userData: |userData-parameter-doc|
	:param EM_BOOL useCapture: |useCapture-parameter-doc|
	:param em_orientationchange_callback_func callback: |callback-function-parameter-doc|
	:returns: :c:data:`EMSCRIPTEN_RESULT_SUCCESS`, or one of the other result values.
	:rtype: |EMSCRIPTEN_RESULT|


.. c:function:: EMSCRIPTEN_RESULT emscripten_get_orientation_status(EmscriptenOrientationChangeEvent *orientationStatus)

	Returns the current device orientation state.

	:param EmscriptenOrientationChangeEvent *orientationStatus: The most recently received orientation state.
	:returns: :c:data:`EMSCRIPTEN_RESULT_SUCCESS`, or one of the other result values.
	:rtype: |EMSCRIPTEN_RESULT|

	
.. c:function:: EMSCRIPTEN_RESULT emscripten_lock_orientation(int allowedOrientations)

	Locks the screen orientation to the given set of allowed orientations.

	:param int allowedOrientations: A bitfield set of :c:data:`EMSCRIPTEN_ORIENTATION_xxx <EMSCRIPTEN_ORIENTATION_PORTRAIT_PRIMARY>` flags.
	:returns: :c:data:`EMSCRIPTEN_RESULT_SUCCESS`, or one of the other result values.
	:rtype: |EMSCRIPTEN_RESULT|


.. c:function:: EMSCRIPTEN_RESULT emscripten_unlock_orientation(void)

	Removes the orientation lock so the screen can turn to any orientation.

	:returns: :c:data:`EMSCRIPTEN_RESULT_SUCCESS`, or one of the other result values.
	:rtype: |EMSCRIPTEN_RESULT|



Fullscreen
==========

Defines
-------

.. c:macro:: EMSCRIPTEN_EVENT_FULLSCREENCHANGE
			 
    Emscripten `fullscreenchange <https://dvcs.w3.org/hg/fullscreen/raw-file/tip/Overview.html>`_ event.

Struct
------

.. c:type:: EmscriptenFullscreenChangeEvent

	The event structure passed in the `fullscreenchange <https://dvcs.w3.org/hg/fullscreen/raw-file/tip/Overview.html>`_ event.
	
	.. c:member:: EM_BOOL isFullscreen
	
		Specifies whether an element on the browser page is currently fullscreen.


	.. c:member:: EM_BOOL fullscreenEnabled
	
		Specifies if the current page has the ability to display elements fullscreen.
		
	.. c:member:: EM_UTF8 nodeName
	
		The `nodeName <https://developer.mozilla.org/en-US/docs/Web/API/Node.nodeName>`_ of the target HTML Element that is in full screen mode. 
		
		Maximum size 128 ``char`` (i.e. ``EM_UTF8 nodeName[128]``).
		
		If ``isFullscreen`` is ``false``, then ``nodeName``, ``id`` and ``elementWidth`` and ``ElementHeight`` specify information about the element that just exited fullscreen mode.
		

	.. c:member:: EM_UTF8 id
	
		The HTML Element ID of the target HTML element that is in full screen mode. 
		
		Maximum size 128 ``char`` (i.e. ``EM_UTF8 id[128]``).

		
	.. c:member:: int elementWidth
		int elementHeight
	
		The new pixel size of the element that changed fullscreen status.

		
	.. c:member:: int screenWidth
		int screenHeight
	
		The size of the whole screen, in pixels.

		
Callback functions
------------------

.. c:type:: em_fullscreenchange_callback_func

	Function pointer for the :c:func:`fullscreen event callback functions <emscripten_set_fullscreenchange_callback>`.

	Defined as: :: 

		typedef EM_BOOL (*em_fullscreenchange_callback_func)(int eventType, const EmscriptenFullscreenChangeEvent *keyEvent, void *userData);
	
	:param int eventType: The type of fullscreen event (:c:data:`EMSCRIPTEN_EVENT_FULLSCREENCHANGE`).
	:param keyEvent: Information about the fullscreen event that occurred.
	:type keyEvent: const EmscriptenFullscreenChangeEvent*
	:param void* userData: The ``userData`` originally passed to the registration function.
	:returns: |callback-handler-return-value-doc|
	:rtype: |EM_BOOL|


	
Functions
--------- 

.. c:function:: EMSCRIPTEN_RESULT emscripten_set_fullscreenchange_callback(const char *target, void *userData, EM_BOOL useCapture, em_fullscreenchange_callback_func callback)
		
	Registers a callback function for receiving the `fullscreenchange <https://dvcs.w3.org/hg/fullscreen/raw-file/tip/Overview.html>`_ event.
	
	:param target: |target-parameter-doc|
	:type target: const char*
	:param void* userData: |userData-parameter-doc|
	:param EM_BOOL useCapture: |useCapture-parameter-doc|
	:param em_fullscreenchange_callback_func callback: |callback-function-parameter-doc|	
	:returns: :c:data:`EMSCRIPTEN_RESULT_SUCCESS`, or one of the other result values.
	:rtype: |EMSCRIPTEN_RESULT|


.. c:function:: EMSCRIPTEN_RESULT emscripten_get_fullscreen_status(EmscriptenFullscreenChangeEvent *fullscreenStatus)

	Returns the current page `fullscreen <https://dvcs.w3.org/hg/fullscreen/raw-file/tip/Overview.html>`_ state.

	:param EmscriptenFullscreenChangeEvent *fullscreenStatus: The most recently received fullscreen state.
	:returns: :c:data:`EMSCRIPTEN_RESULT_SUCCESS`, or one of the other result values.
	:rtype: |EMSCRIPTEN_RESULT|


.. c:function:: EMSCRIPTEN_RESULT emscripten_request_fullscreen(const char *target, EM_BOOL deferUntilInEventHandler)

	Requests the given target element to transition to full screen mode.
	
	.. note:: This function can be called anywhere, but for web security reasons its associated *request* can only be raised inside the event handler for a user-generated event (for example a key, mouse or touch press/release). This has implications for porting and the value of ``deferUntilInEventHandler``  - see :ref:`web-security-functions-html5-api` for more information.

	:param target: |target-parameter-doc|
	:type target: const char*
	:param EM_BOOL deferUntilInEventHandler: If ``true`` requests made outside of a user-generated event handler are automatically deferred until the user next presses a keyboard or mouse button. If ``false`` the request will fail if called outside of a user-generated event handler.
	
	:returns: :c:data:`EMSCRIPTEN_RESULT_SUCCESS`, or one of the other result values.
	:rtype: **EMSCRIPTEN_RESULT**
	

.. c:function:: EMSCRIPTEN_RESULT emscripten_exit_fullscreen(void)

	Returns back to windowed browsing mode.

	:returns: :c:data:`EMSCRIPTEN_RESULT_SUCCESS`, or one of the other result values.
	:rtype: |EMSCRIPTEN_RESULT|



Pointerlock 
===========

Defines
-------

.. c:macro:: EMSCRIPTEN_EVENT_POINTERLOCKCHANGE
			 
    Emscripten `pointerlockchange <http://www.w3.org/TR/pointerlock/#pointerlockchange-and-pointerlockerror-events>`_ events.
	

Struct
------

.. c:type:: EmscriptenPointerlockChangeEvent

	The event structure passed in the `pointerlockchange <http://www.w3.org/TR/pointerlock/#pointerlockchange-and-pointerlockerror-events>`_ event.

	
	.. c:member:: EM_BOOL isActive
	
		Specifies whether an element on the browser page currently has pointer lock enabled.

	.. c:member:: EM_UTF8 nodeName
	
		The `nodeName <https://developer.mozilla.org/en-US/docs/Web/API/Node.nodeName>`_ of the target HTML Element that has the pointer lock active. 
		
		Maximum size 128 ``char`` (i.e. ``EM_UTF8 nodeName[128]``).
		
	.. c:member:: EM_UTF8 id
	
		The HTML Element ID of the target HTML element that has the pointer lock active. 
		
		Maximum size 128 ``char`` (i.e. ``EM_UTF8 id[128]``).


Callback functions
------------------

.. c:type:: em_pointerlockchange_callback_func

	Function pointer for the :c:func:`pointerlockchange event callback functions <emscripten_set_pointerlockchange_callback>`.

	Defined as: :: 

		typedef EM_BOOL (*em_pointerlockchange_callback_func)(int eventType, const EmscriptenPointerlockChangeEvent *keyEvent, void *userData);
	
	:param int eventType: The type of pointerlockchange event (:c:data:`EMSCRIPTEN_EVENT_POINTERLOCKCHANGE`).
	:param keyEvent: Information about the pointerlockchange event that occurred.
	:type keyEvent: const EmscriptenPointerlockChangeEvent*
	:param void* userData: The ``userData`` originally passed to the registration function.
	:returns: |callback-handler-return-value-doc|
	:rtype: |EM_BOOL|
	

	
Functions
--------- 

.. c:function:: EMSCRIPTEN_RESULT emscripten_set_pointerlockchange_callback(const char *target, void *userData, EM_BOOL useCapture, em_pointerlockchange_callback_func callback)
		
	Registers a callback function for receiving the `pointerlockchange <http://www.w3.org/TR/pointerlock/#pointerlockchange-and-pointerlockerror-events>`_ event.
	
	Pointer lock hides the mouse cursor and exclusively gives the target element relative mouse movement events via the `mousemove <https://dvcs.w3.org/hg/dom3events/raw-file/tip/html/DOM3-Events.html#event-type-mousemove>`_ event.

	:param target: |target-parameter-doc|
	:type target: const char*
	:param void* userData: |userData-parameter-doc|
	:param EM_BOOL useCapture: |useCapture-parameter-doc|
	:param em_pointerlockchange_callback_func callback: |callback-function-parameter-doc|
	:returns: :c:data:`EMSCRIPTEN_RESULT_SUCCESS`, or one of the other result values.
	:rtype: |EMSCRIPTEN_RESULT|



.. c:function:: EMSCRIPTEN_RESULT emscripten_get_pointerlock_status(EmscriptenPointerlockChangeEvent *pointerlockStatus)

	Returns the current page pointerlock state.

	:param EmscriptenPointerlockChangeEvent* pointerlockStatus: The most recently received pointerlock state.
	:returns: :c:data:`EMSCRIPTEN_RESULT_SUCCESS`, or one of the other result values.
	:rtype: |EMSCRIPTEN_RESULT|

	
.. c:function:: EMSCRIPTEN_RESULT emscripten_request_pointerlock(const char *target, EM_BOOL deferUntilInEventHandler)

	Requests the given target element to grab pointerlock.
	
	.. note:: This function can be called anywhere, but for web security reasons its associated *request* can only be raised inside the event handler for a user-generated event (for example a key, mouse or touch press/release). This has implications for porting and the value of ``deferUntilInEventHandler``  - see :ref:`web-security-functions-html5-api` for more information.

		
	:param target: |target-parameter-doc|
	:type target: const char*
	:param EM_BOOL deferUntilInEventHandler: If ``true`` requests made outside of a user-generated event handler are automatically deferred until the user next presses a keyboard or mouse button. If ``false`` the request will fail if called outside of a user-generated event handler.
	:returns: :c:data:`EMSCRIPTEN_RESULT_SUCCESS`, or one of the other result values.
	:rtype: |EMSCRIPTEN_RESULT|


.. c:function:: EMSCRIPTEN_RESULT emscripten_exit_pointerlock(void)

	Exits pointer lock state and restores the mouse cursor to be visible again.

	:returns: :c:data:`EMSCRIPTEN_RESULT_SUCCESS`, or one of the other result values.
	:rtype: |EMSCRIPTEN_RESULT|

	


Visibility
==========

Defines
-------

.. c:macro:: EMSCRIPTEN_EVENT_VISIBILITYCHANGE
			 
    Emscripten `visibilitychange <http://www.w3.org/TR/page-visibility/#sec-visibilitychange-event>`_ event.


.. c:macro:: EMSCRIPTEN_VISIBILITY_HIDDEN

	The document is `hidden <http://www.w3.org/TR/page-visibility/#pv-page-hidden>`_ (not visible).
	
.. c:macro:: EMSCRIPTEN_VISIBILITY_VISIBLE

	The document is at least partially `visible <http://www.w3.org/TR/page-visibility/#pv-page-visible>`_.

.. c:macro:: EMSCRIPTEN_VISIBILITY_PRERENDER

	The document is loaded off screen and not visible (`prerender <http://www.w3.org/TR/page-visibility/#pv-prerender>`_).

.. c:macro:: EMSCRIPTEN_VISIBILITY_UNLOADED

	The document is to be `unloaded <http://www.w3.org/TR/page-visibility/#pv-unloaded>`_.


Struct
------

.. c:type:: EmscriptenVisibilityChangeEvent

	The event structure passed in the `visibilitychange <http://www.w3.org/TR/page-visibility/>`_ event. 
		
	
	.. c:member:: EM_BOOL hidden
	
		If true, the current browser page is now hidden.
  

	.. c:member:: int visibilityState
	
		Specifies a more fine-grained state of the current page visibility status. One of the EMSCRIPTEN_VISIBILITY_ values.
		

Callback functions
------------------

.. c:type:: em_visibilitychange_callback_func

	Function pointer for the :c:func:`visibilitychange event callback functions <emscripten_set_visibilitychange_callback>`.

	Defined as: :: 

		typedef EM_BOOL (*em_visibilitychange_callback_func)(int eventType, const EmscriptenVisibilityChangeEvent *keyEvent, void *userData);
	
	:param int eventType: The type of visibilitychange event (:c:data:`EMSCRIPTEN_VISIBILITY_HIDDEN`).
	:param keyEvent: Information about the visibilitychange event that occurred.
	:type keyEvent: const EmscriptenVisibilityChangeEvent*
	:param void* userData: The ``userData`` originally passed to the registration function.
	:returns: |callback-handler-return-value-doc|
	:rtype: |EM_BOOL|

		
Functions
--------- 

.. c:function:: EMSCRIPTEN_RESULT emscripten_set_visibilitychange_callback(void *userData, EM_BOOL useCapture, em_visibilitychange_callback_func callback)
		
	Registers a callback function for receiving the `visibilitychange <http://www.w3.org/TR/page-visibility/>`_ event.

	:param void* userData: |userData-parameter-doc|
	:param EM_BOOL useCapture: |useCapture-parameter-doc|
	:param em_visibilitychange_callback_func callback: |callback-function-parameter-doc|
	:returns: :c:data:`EMSCRIPTEN_RESULT_SUCCESS`, or one of the other result values.
	:rtype: |EMSCRIPTEN_RESULT|


.. c:function:: EMSCRIPTEN_RESULT emscripten_get_visibility_status(EmscriptenVisibilityChangeEvent *visibilityStatus)

	Returns the current page visibility state.

	:param EmscriptenVisibilityChangeEvent* visibilityStatus: The most recently received page visibility state.
	:returns: :c:data:`EMSCRIPTEN_RESULT_SUCCESS`, or one of the other result values.
	:rtype: |EMSCRIPTEN_RESULT|



Touch
=====

Defines
-------

.. c:macro:: EMSCRIPTEN_EVENT_TOUCHSTART
	EMSCRIPTEN_EVENT_TOUCHEND
	EMSCRIPTEN_EVENT_TOUCHMOVE
	EMSCRIPTEN_EVENT_TOUCHCANCEL
			 
    Emscripten touch events.

	
Struct
------

.. c:type:: EmscriptenTouchPoint

	Specifies the status of a single `touch point <http://www.w3.org/TR/touch-events/#touch-interface>`_ on the page.
	
	.. c:member:: long identifier
	
		An identification number for each touch point.

	.. c:member:: long screenX
		long screenY
	
		The touch coordinate relative to the whole screen origin, in pixels.
		
	.. c:member:: long clientX
		long clientY
	
		The touch coordinate relative to the viewport, in pixels.

	.. c:member:: long pageX
		long pageY
	
		The touch coordinate relative to the viewport, in pixels, and including any scroll offset.

	.. c:member:: EM_BOOL isChanged
	
		Specifies whether this touch point changed during this event.
		
	.. c:member:: EM_BOOL onTarget
	
		Specifies whether this touch point is still above the original target on which it was initially pressed against.		
		
	.. c:member:: long canvasX
		long canvasY
	
		The touch coordinates mapped to the Emscripten canvas client area, in pixels.		


		
.. c:type:: EmscriptenTouchEvent

	Specifies the data of a single `touchevent <http://www.w3.org/TR/touch-events/#touchevent-interface>`_.
	
	.. c:member:: int numTouches
	
		The number of valid elements in the touches array.
  

	.. c:member:: EM_BOOL ctrlKey
		EM_BOOL shiftKey
		EM_BOOL altKey
		EM_BOOL metaKey
	
		Specifies which modifiers were active during the key event.
		
	.. c:member:: EmscriptenTouchPoint touches[32]
	
		An array of currently active touches, one for each finger.
		

		
Callback functions
------------------


.. c:type:: em_touch_callback_func

	Function pointer for the :c:func:`touch event callback functions <emscripten_set_touchstart_callback>`.

	Defined as: :: 

		typedef EM_BOOL (*em_touch_callback_func)(int eventType, const EmscriptenTouchEvent *keyEvent, void *userData);
	
	:param int eventType: The type of touch event (:c:data:`EMSCRIPTEN_EVENT_TOUCHSTART`).
	:param keyEvent: Information about the touch event that occurred.
	:type keyEvent: const EmscriptenTouchEvent*
	:param void* userData: The ``userData`` originally passed to the registration function.
	:returns: |callback-handler-return-value-doc|
	:rtype: |EM_BOOL|

	
		
Functions
--------- 

.. c:function:: EMSCRIPTEN_RESULT emscripten_set_touchstart_callback(const char *target, void *userData, EM_BOOL useCapture, em_touch_callback_func callback)
	EMSCRIPTEN_RESULT emscripten_set_touchend_callback(const char *target, void *userData, EM_BOOL useCapture, em_touch_callback_func callback)
	EMSCRIPTEN_RESULT emscripten_set_touchmove_callback(const char *target, void *userData, EM_BOOL useCapture, em_touch_callback_func callback)
	EMSCRIPTEN_RESULT emscripten_set_touchcancel_callback(const char *target, void *userData, EM_BOOL useCapture, em_touch_callback_func callback)

	Registers a callback function for receiving `touch events <http://www.w3.org/TR/touch-events/)>`_ : `touchstart <http://www.w3.org/TR/touch-events/#the-touchstart-event>`_, `touchend <http://www.w3.org/TR/touch-events/#dfn-touchend>`_, `touchmove <http://www.w3.org/TR/touch-events/#dfn-touchmove>`_ and `touchcancel <http://www.w3.org/TR/touch-events/#dfn-touchcancel>`_.

	:param target: |target-parameter-doc|
	:type target: const char*
	:param void* userData: |userData-parameter-doc|
	:param EM_BOOL useCapture: |useCapture-parameter-doc|
	:param em_touch_callback_func callback: |callback-function-parameter-doc|
	:returns: :c:data:`EMSCRIPTEN_RESULT_SUCCESS`, or one of the other result values.
	:rtype: |EMSCRIPTEN_RESULT|



Gamepad
=======

Defines
-------

.. c:macro:: EMSCRIPTEN_EVENT_GAMEPADCONNECTED
	EMSCRIPTEN_EVENT_GAMEPADDISCONNECTED
			 
    Emscripten `gamepad <http://www.w3.org/TR/gamepad/#gamepad-interface>`_ events.


Struct
------

.. c:type:: EmscriptenGamepadEvent

	Represents the current snapshot state of a `gamepad <http://www.w3.org/TR/gamepad/#gamepad-interface>`_.
	
	
	.. c:member:: double timestamp
	
		Absolute wallclock time when the data was recorded (milliseconds).

	.. c:member:: int numAxes
	
		The number of valid axes entries in the axis array.
		
	.. c:member:: int numButtons
	
		The number of valid button entries in the analogButton and digitalButton arrays.

	.. c:member:: double axis[64]
	
		The analog state of the gamepad axes, in the range [-1, 1].


	.. c:member:: double analogButton[64]
	
		The analog state of the gamepad buttons, in the range [0, 1].

		
	.. c:member:: EM_BOOL digitalButton[64]
	
		The digital state of the gamepad buttons, either 0 or 1.		

	.. c:member:: EM_BOOL connected
	
		Specifies whether this gamepad is connected to the browser page.	

	.. c:member:: long index
	
		An ordinal associated with this gamepad, zero-based.	

	.. c:member:: EM_UTF8 id
	
		An ID for the brand or style of the connected gamepad device. Typically, this will include the USB vendor and a product ID. 
		
		Maximum size 64 ``char`` (i.e. ``EM_UTF8 id[128]``).
  
	.. c:member:: EM_UTF8 mapping
	
		A string that identifies the layout or control mapping of this device. 
		
		Maximum size 128 ``char`` (i.e. ``EM_UTF8 mapping[128]``).


		
Callback functions
------------------

.. c:type:: em_gamepad_callback_func

	Function pointer for the :c:func:`gamepad event callback functions <emscripten_set_gamepadconnected_callback>`.

	Defined as: :: 

		typedef EM_BOOL (*em_gamepad_callback_func)(int eventType, const EmscriptenGamepadEvent *keyEvent, void *userData)
	
	:param int eventType: The type of gamepad event (:c:data:`EMSCRIPTEN_EVENT_GAMEPADCONNECTED`).
	:param keyEvent: Information about the gamepad event that occurred.
	:type keyEvent: const EmscriptenGamepadEvent*
	:param void* userData: The ``userData`` originally passed to the registration function.
	:returns: |callback-handler-return-value-doc|
	:rtype: |EM_BOOL|		
	
	
		
Functions
--------- 

.. c:function:: EMSCRIPTEN_RESULT emscripten_set_gamepadconnected_callback(void *userData, EM_BOOL useCapture, em_gamepad_callback_func callback)
	EMSCRIPTEN_RESULT emscripten_set_gamepaddisconnected_callback(void *userData, EM_BOOL useCapture, em_gamepad_callback_func callback)
		
	Registers a callback function for receiving the `gamepad <http://www.w3.org/TR/gamepad/>`_ events: `gamepadconnected <http://www.w3.org/TR/gamepad/#the-gamepadconnected-event>`_ and `gamepaddisconnected <http://www.w3.org/TR/gamepad/#the-gamepaddisconnected-event>`_.

	:param void* userData: |userData-parameter-doc|
	:param EM_BOOL useCapture: |useCapture-parameter-doc|
	:param em_gamepad_callback_func callback: |callback-function-parameter-doc|
	:returns: :c:data:`EMSCRIPTEN_RESULT_SUCCESS`, or one of the other result values.
	:rtype: |EMSCRIPTEN_RESULT|	


.. c:function:: int emscripten_get_num_gamepads(void)

	Returns the number of gamepads connected to the system or :c:type:`EMSCRIPTEN_RESULT_NOT_SUPPORTED` if the current browser does not support gamepads.
	
	.. note:: A gamepad does not show up as connected until a button on it is pressed.

	:returns: :c:data:`EMSCRIPTEN_RESULT_SUCCESS`, or one of the other result values.
	:rtype: int


.. c:function:: EMSCRIPTEN_RESULT emscripten_get_gamepad_status(int index, EmscriptenGamepadEvent *gamepadState);

	Returns a snapshot of the current gamepad state.

	:param int index: The index of the gamepad to check (in the `array of connected gamepads <https://developer.mozilla.org/en-US/docs/Web/API/Navigator.getGamepads>`_).
	:param EmscriptenGamepadEvent* gamepadState: The most recently received gamepad state.
	:returns: :c:data:`EMSCRIPTEN_RESULT_SUCCESS`, or one of the other result values.
	:rtype: |EMSCRIPTEN_RESULT|



Battery
=======

Defines
-------

.. c:macro:: EMSCRIPTEN_EVENT_BATTERYCHARGINGCHANGE
	EMSCRIPTEN_EVENT_BATTERYLEVELCHANGE
			 
    Emscripten `batterymanager <http://www.w3.org/TR/battery-status/#batterymanager-interface>`_ events.

	
Struct
------

.. c:type:: EmscriptenBatteryEvent

	The event structure passed in the `batterymanager <http://www.w3.org/TR/battery-status/#batterymanager-interface>`_ events: ``chargingchange`` and ``levelchange``.

	
	.. c:member:: double chargingTime
	
		Time remaining until the battery is fully charged (seconds).

	.. c:member:: double dischargingTime
	
		Time remaining until the battery is empty and the system will be suspended (seconds).
		
	.. c:member:: double level
	
		Current battery level, on a scale of 0 to 1.0.

	.. c:member::  EM_BOOL charging;
	
		``true`` if the batter is charging, ``false`` otherwise.

		
Callback functions
------------------

.. c:type:: em_battery_callback_func

	Function pointer for the :c:func:`batterymanager event callback functions <emscripten_set_batterychargingchange_callback>`.

	Defined as: :: 

		typedef EM_BOOL (*em_battery_callback_func)(int eventType, const EmscriptenBatteryEvent *keyEvent, void *userData);
	
	:param int eventType: The type of batterymanager event (:c:data:`EMSCRIPTEN_EVENT_BATTERYCHARGINGCHANGE`).
	:param keyEvent: Information about the batterymanager event that occurred.
	:type keyEvent: const EmscriptenBatteryEvent*
	:param void* userData: The ``userData`` originally passed to the registration function.
	:returns: |callback-handler-return-value-doc|
	:rtype: |EM_BOOL|

			
		
Functions
--------- 

.. c:function:: EMSCRIPTEN_RESULT emscripten_set_batterychargingchange_callback(void *userData, em_battery_callback_func callback)
	EMSCRIPTEN_RESULT emscripten_set_batterylevelchange_callback(void *userData, em_battery_callback_func callback)
		
	Registers a callback function for receiving the `batterymanager <http://www.w3.org/TR/battery-status/#batterymanager-interface>`_ events: ``chargingchange`` and ``levelchange``.

	:param void* userData: |userData-parameter-doc|
	:param EM_BOOL useCapture: |useCapture-parameter-doc|
	:param em_battery_callback_func callback: |callback-function-parameter-doc|
	:returns: :c:data:`EMSCRIPTEN_RESULT_SUCCESS`, or one of the other result values.
	:rtype: |EMSCRIPTEN_RESULT|	


.. c:function:: EMSCRIPTEN_RESULT emscripten_get_battery_status(EmscriptenBatteryEvent *batteryState)

	Returns the current battery status.

	:param EmscriptenBatteryEvent *batteryState: The most recently received battery state.
	:returns: :c:data:`EMSCRIPTEN_RESULT_SUCCESS`, or one of the other result values.
	:rtype: |EMSCRIPTEN_RESULT|



Vibration
=========

Functions
--------- 


.. c:function:: EMSCRIPTEN_RESULT emscripten_vibrate(int msecs)

	Produces a `vibration <http://dev.w3.org/2009/dap/vibration/>`_ for the specified time, in milliseconds.

	:param int msecs: The amount of time for which the vibration is required (milliseconds)
	:returns: :c:data:`EMSCRIPTEN_RESULT_SUCCESS`, or one of the other result values.
	:rtype: |EMSCRIPTEN_RESULT|


.. c:function:: EMSCRIPTEN_RESULT emscripten_vibrate_pattern(int *msecsArray, int numEntries)

	Produces a complex vibration feedback pattern.

	:param int* msecsArray: An array of timing entries [on, off, on, off, on, off, ...] where every second one specifies a duration of vibration, and every other one specifies a duration of silence.
	:param int numEntries: The number of integers in the array ``msecsArray``.
	:returns: :c:data:`EMSCRIPTEN_RESULT_SUCCESS`, or one of the other result values.
	:rtype: |EMSCRIPTEN_RESULT|


Page unload
===========

Defines
-------

.. c:macro:: EMSCRIPTEN_EVENT_BEFOREUNLOAD
			 
    Emscripten `beforeunload <http://www.whatwg.org/specs/web-apps/current-work/multipage/history.html#beforeunloadevent>`_ event.
	

Callback functions
------------------

.. c:type:: em_beforeunload_callback

	Function pointer for the :c:func:`beforeunload event callback functions <emscripten_set_beforeunload_callback>`.

	Defined as: :: 

		typedef const char *(*em_beforeunload_callback)(int eventType, const void *reserved, void *userData);
	
	:param int eventType: The type of beforeunload event (:c:data:`EMSCRIPTEN_EVENT_BEFOREUNLOAD`).
	:param reserved: Reserved for future use; pass in 0.
	:type reserved: const void*
	:param void* userData: The ``userData`` originally passed to the registration function.
	:returns: Return a string to be displayed to the user.
	:rtype: char*
	
	
	
Functions
---------


.. c:function:: EMSCRIPTEN_RESULT emscripten_set_beforeunload_callback(void *userData, em_beforeunload_callback callback)
		
	Registers a callback function for receiving the page `beforeunload <http://www.whatwg.org/specs/web-apps/current-work/multipage/history.html#beforeunloadevent>`_ event.
	
	Hook onto this event to perform actions immediately prior to page close (for example, to display a notification to ask if the user really wants to leave the page). 

	:param void* userData: |userData-parameter-doc|
	:param em_beforeunload_callback callback: |callback-function-parameter-doc|
	:returns: :c:data:`EMSCRIPTEN_RESULT_SUCCESS`, or one of the other result values.
	:rtype: |EMSCRIPTEN_RESULT|
	


WebGL context
=============

Defines
-------

.. c:macro:: EMSCRIPTEN_EVENT_WEBGLCONTEXTLOST
	EMSCRIPTEN_EVENT_WEBGLCONTEXTRESTORED
			 
    Emscripten `WebGL context <http://www.khronos.org/registry/webgl/specs/latest/1.0/#5.15.2>`_ events.

	
Callback functions
------------------


.. c:type:: em_webgl_context_callback

	Function pointer for the :c:func:`WebGL Context event callback functions <emscripten_set_webglcontextlost_callback>`.

	Defined as: :: 

		typedef EM_BOOL (*em_webgl_context_callback)(int eventType, const void *reserved, void *userData);
	
	:param int eventType: The type of :c:data:`WebGL context event <EMSCRIPTEN_EVENT_WEBGLCONTEXTLOST>`.
	:param reserved: Reserved for future use; pass in 0.
	:type reserved: const void*
	:param void* userData: The ``userData`` originally passed to the registration function.
	:returns: |callback-handler-return-value-doc|
	:rtype: |EM_BOOL|
		
	

Functions
---------


.. c:function:: EMSCRIPTEN_RESULT emscripten_set_webglcontextlost_callback(const char *target, void *userData, EM_BOOL useCapture, em_webgl_context_callback callback)
	EMSCRIPTEN_RESULT emscripten_set_webglcontextrestored_callback(const char *target, void *userData, EM_BOOL useCapture, em_webgl_context_callback callback)

	Registers a callback function for the canvas `WebGL context <http://www.khronos.org/registry/webgl/specs/latest/1.0/#5.15.2>`_ events: ``webglcontextlost`` and ``webglcontextrestored``.

	:param target: |target-parameter-doc|
	:type target: const char*
	:param void* userData: |userData-parameter-doc|
	:param EM_BOOL useCapture: |useCapture-parameter-doc|
	:param em_webgl_context_callback callback: |callback-function-parameter-doc|
	:returns: :c:data:`EMSCRIPTEN_RESULT_SUCCESS`, or one of the other result values.
	:rtype: |EMSCRIPTEN_RESULT|



.. c:function:: EM_BOOL emscripten_is_webgl_context_lost(const char *target)

	Queries the given canvas element for whether its WebGL context is in a lost state.

	:param const char *target: Reserved for future use, pass in 0.
	:returns: ``true`` if the WebGL context is in a lost state.
	:rtype: |EM_BOOL|

	
	
.. COMMENT (not rendered): Section below is automated copy and replace text.

.. COMMENT (not rendered): The replace function return values with links (not created automatically)
	
.. |EMSCRIPTEN_RESULT| replace:: :c:type:`EMSCRIPTEN_RESULT`
.. |EM_BOOL| replace:: :c:type:`EM_BOOL`

.. COMMENT (not rendered): Following values are common to many functions, and currently only updated in one place (here).
.. COMMENT (not rendered): These can be properly replaced if required either wholesale or on an individual basis.

.. |target-parameter-doc| replace:: :ref:`Target HTML element id <target-parameter-html5-api>`.
.. |userData-parameter-doc| replace:: :ref:`User-defined data <userdata-parameter-html5-api>` to be passed to the callback (opaque to the API).
.. |useCapture-parameter-doc| replace:: Set ``true`` to :ref:`use capture <usecapture-parameter-html5-api>`.
.. |callback-handler-return-value-doc| replace:: Return ``true`` (non zero) to indicate that the event was consumed by the :ref:`callback handler <callback-handler-return-em_bool-html5-api>`.
.. |callback-function-parameter-doc| replace:: A callback function. The function is called with the type of event, information about the event, and user data passed from this registration function. The callback should return ``true`` if the event is consumed.	



