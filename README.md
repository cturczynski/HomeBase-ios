# HomeBase-ios

HomeBase is a practice project that I made to work on my new React.js and Node.js skills, as well as brush back up on my Swift and iOS development skills. It was inspired by my time bartending this past year and the scheduling system we used for our schedules. The entire project is comprised of:
* React web app
* Node backend
* MySQL database
* __iOS application__

The React & Node app can be found in my other repository [here](https://github.com/cturczynski/HomeBase).

The node backend serves API endpoints to both the web app and the iOS app to access the database. This component, the iOS application, was built for these functionality goals:
* Allow employees to clock in/out and see their timeclock history (Timeclock tab)
* Provide a tipsheet for the current day so the only math the employees have to do is counting out the money at the end of the day (Tip Sheet tab)
* Show the user their previous days' income with brief details on their shift(s) that day (Your Income tab)
* Display the current user's profile info and allow them to change their profile picture (Profile tab)

As hoped, I found this project helped me hit many of the standard iOS development practices that are useful and needed in modern day development:
* Storyboard UI
* Auto Layout
* Classes/Structs/Enums
* do-try-catch statements
* if-let/guard statements
* UIImagePickerController
* REST calls/callbacks
* Codable/Encodable/Decodable protocols
* Async/Await pattern
* Tasks
* DispatchQueue
* DispatchGroup
* Error handling
* Generics
* Appropriate logging

The app can be download and ran as is. Make sure to run "pod install" or "pod update" for the dependencies. The API calls are being served by the node server deployed on Heroku. You can create a new user on the Login screen by inputting your desired username and password "admin". Randomized data will be populated weekly for regular use.
