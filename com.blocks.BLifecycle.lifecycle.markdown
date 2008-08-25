Use this extension point if your plugin needs to get a callback at a particular stage in the application's lifecyle. These callbacks map to the standard NSApplication callbacks, except `applicationMayTerminateNotification` which will get called when the application is asked to terminate, but before anyone has a chance to cancel the terminate process, and `applicationCancledTerminateNotification` wich gets called if the terminate process is cancled. The reason for using these callbacks, as opposed to registering with `NSNotificationCenter` to get them is that by using these callbacks you plugin code doesn't need to get loaded until the moment that it is needed.

## Examples:

In this configuration example the object returned by `[MyController sharedInstance]` will be sent callback messages at each stage of the application's lifecycle. This configuration markup should be added to the Plugin.xml file of the plugin that declares the `MyController` class.

    <extension point="com.blocks.BLifecycle.lifecycle">
        <applicationLaunching class="MyController sharedInstance" />
        <applicationWillFinishLaunching class="MyController sharedInstance" />
        <applicationDidFinishLaunching class="MyController sharedInstance" />
        <applicationMayTerminateNotification class="MyController sharedInstance" />
        <applicationCancledTerminateNotification class="MyController sharedInstance" />
        <applicationWillTerminate class="MyController sharedInstance" />
    </extension>

`MyController` should implement the following methods:

    @implementation MyController
    - (void)applicationLaunching { }   
    - (void)applicationWillFinishLaunching { }
    - (void)applicationDidFinishLaunching { }    
    - (void)applicationMayTerminateNotification { }
	- (void)applicationCancledTerminateNotification { }
    - (void)applicationWillTerminate { }
    @end
	
Normally a single controller won't need to get all those callbacks. If you don't need a particular callback just leave out that configuration element in the extension, and then you don't need to implment the callback method.