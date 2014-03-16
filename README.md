Final Project
The final project for this class will involve both a cloud and native component. There should be
interfaces for both sides and they will need to communicate with each other.
Requirements
Native Application
The native application, that is, the one that runs on a mobile device, needs to leverage at least
one feature that stands out in terms of native applications. This might be the camera, 3d
rendering of graphics or using the accelerometer. Essentially it needs to be something that
would not be easy to accomplish using a cloud application. It should at least send data to the
cloud portion of the application. Optionally it may pull data from the cloud portion as well.
Cloud Application
The cloud application will be hosted on GAE (or with approval, another cloud service) and will
provide a web interface to access data sent by the native application. It should use a cron job to
periodically do meaningful work the data sent by the native application.
Other Requirements
You need to implement something that goes beyond the scope of the material covered in class.
A good option to do this is to implement one of the features described in a fellow classmates
how­to guide.
Deliverables
1. You will submit two zip files, one containing the native source code and one containing
the mobile source code.
2. You will make and host a ~5 minute video demoing your native application and provide a
link to that video.
3. You will provide a link to the live, hosted cloud application.
