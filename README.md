# How to Run App
Simple Camera App have camera functionality so need to run on real device to use simple camera app, Connect real device with Mac and find your device in xcode run schema.
select your device and hit the run button.

# Free provisioning/testing on your device:

• From within Xcode 7.x or higher (Mac only), navigate to “Xcode—->Preferences—->Accounts.” Hit the '+' icon below left to add your Apple ID*. After you add your account, 
  it will show within the main account window on the right.

• Select your account, hit the “View Details” button and wait (be patient) for them to load.

• Now create the 'signing identity' used to create a provisioning profile used for device testing - Hit the “Create” button next to the 'iOS development' label.
  When completed, hit ‘Done’. If the create button is dimmed, continue waiting for the process to complete.

• Connect your device (cable only, not wireless) and select it as build destination via the 'active scheme' dropdown to the right of the play and stop icons.

• In target's 'General' tab/settings:

• a. Set app identifier you want for your free profile

• b. Set team id as your apple id

• c. Hit 'Fix Issue' button below the provisioning profile warning

 You may have to ‘Fix Issue' more than once - keep at it so Xcode can step thru them as needed.
  
• Run your app with your device selected.**

# Simple Camera App Functionality

Take Photo on Device camera app

Add filter on photo with two filter available

Add Text on photo

Share photo with Actionsheet with available apps on device.


