# iOS-Permissions

This app demonstrates four privacy issues existing in iOS 13. 


## Camera Permission

It uses the permission for Camera Usage to save single frames of the AVCaptureVideoDataOutputSampleBufferDelegate of an active AVCaptureSession connected to a camera, while the preview is hidden. This shows that apps could potentially spy on users through both cameras.


## Photo Library Permission

This permission allows apps to read all media in the Photos app, both on the device and the cloud. Additionally apps can read the connected metadata of the media files. Metadata can hold privacy sensitive data like device information and exact gps coordinates.

## Microphone Permission

Microphones can be recorded at any time without notification on the device.

## Sensors

The accelerationmeter,  gyroscope, magnetometer and other sensors can be read by any app without permission.
