# RemCardsProject

RemCards is essentially a simple reminder app with students in mind. A RemCard has a field for subject name or code, the activity name, deadline for the activity, and level of priority. It also shows the progress you have had on a particular activity through an icon. It is a small project that I made for myself.

The project had different iterations wherein I have tried coding it in different platforms. 

 - RemCards Android Java - An Android project that uses Java as the programming language. It uses the real-time database of Firbase to store the user's data and update it in all logged-in devices.
   You can download the latest build [here](../main/RemCardsApp-AndroidJava/apks/RemCards2_0.apk)
 - RemCards Web - A simple web app that I have created using JavaScript, Bootstrap, HTML, and CSS. Like the Andrid Java app, it uses the Firebase Real-Time database to add, store, delete, and show RemCards of the user. It is also hosted on Firebase.
   You can access the web app through: https://remcards.web.app/
 - RemCards Flutter - A newer iteration of the RemCards app where I use Flutter as my platform of choice. It uses my own API which I have deployed on Heroku. I use MonggoDB for the database. A Schedule feature has been added where the user can input their class schedule and the app would remind them of their class 5 minutes before the period. It does not support real-time updates of RemCards, as opposed to the Android Java version.
   You can download the latest build [here](../main/RemCardsApp-Flutter/remcards/apks/RemCards-FL220427.apk)
