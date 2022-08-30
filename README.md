# StriderChallenge
Social Media App like Twitter made for Strider

# Used:
KingFisher<br/>
SDWebImage<br/>
Firebase<br/>
Crashlytics<br/>
URLSession - Future scaling <br/>
MVVM Arch<br/>
Bindable<br/>
Localizable<br/>

# How to run

Please before run the project, make sure that you've runned the pod install and open the project by clicking on StriderChallenge.xcworkspace

# Critique

The project was made using Firebase but in the future, for good project scaling we should improve our own API. Also, Firebase allows you to run your application offline.

One big problem of this project is the missing unit tests implementation and also, UI Testing. We should do that before send it to production.

By purpose, I made completions block use plus bindables. We could avoid this implementing Bindables with Pairs, something like Bindable<LeftValue, RightValue>. In the PostRepository, we're receiving the UserRepository but we could improve it setting the UserRepository as a singleton plus, which allows us to define a singleton and create a new instance when it needed. 

The project was made in MVVM-C, but it should be improved.

I also let a enum for messages, then we can build notification viewController and message chat for the users.
PostViewModel has a massive postService injected. We could solve it by setting a singleton.

# Assuming you've got multiple crash reports and reviews saying the app is not working properly and is slow for specific models, what would be your strategy to tackle the problem? 

I implemented the Crashlytics, which is good for the project because once we have multiple crashes, we need the Firebase crashlytics to tell us where we need to find the problem. If you guys need to check the dashboard, you can use this account. email: strider.challenge@gmail.com | password: striderChallenge2022! Everything is already configured. Here is the link: https://console.firebase.google.com/u/0/project/striderchallenge-4d39b/crashlytics/app/ios:com.renatomateusx.striderchallenge/issues

# Assuming your app has now thousands of users thus a lot of posts to show in the feed. What do you believe should be improved in this initial version and what strategies/proposals you could formulate for such a challenge?

I understand that the architecture of the project should be good enought to support the project scaling, that is the reason I chose the MVVM-C pattern. Also, I know that in the future we should replace the Firebase to a AWS API that can be more scaled.


