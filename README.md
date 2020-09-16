# iOS-Permissions

This app demonstrates four privacy issues existing in iOS 13. 


## Camera Permission

It uses the permission for Camera Usage to save single frames of the AVCaptureVideoDataOutputSampleBufferDelegate of an active AVCaptureSession connected to a camera, while the preview is hidden. This shows that apps could potentially spy on users through both cameras.

<img src="https://user-images.githubusercontent.com/33352637/93338466-a8a63080-f82a-11ea-9bea-b87391e87c40.png" width="200">


## Photo Library Permission

This permission allows apps to read all media in the Photos app, both on the device and the cloud. Additionally apps can read the connected metadata of the media files. Metadata can hold privacy sensitive data like device information and exact gps coordinates.

<img src="https://user-images.githubusercontent.com/33352637/93338051-346b8d00-f82a-11ea-9a17-797211b6f7ad.png" width="200">


## Microphone Permission

Microphones can be recorded at any time without notification on the device.

## Sensors

The accelerationmeter,  gyroscope, magnetometer and other sensors can be read by any app without permission.
