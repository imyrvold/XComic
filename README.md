# XComic
XComic is a SwiftUI app for iOS, that pulls comics strips form xkcd.com, and shows the comic strip image with additional information on the front view of the app.

The user can get additional information about the current displayed comic strip by tapping the info button.

## SwiftUI implementation
I made the decision to do the challenge using SwiftUI, because i figured that would be the easiest for me to complete most of the requirements. SwiftUI also have the preview, which is absolutely magnificent in that it makes you iterating over the design of the views and you can see the results immediately in the preview.

As I am nearing the completion of the requirements, I can now do most of the functions of the app in the preview.

## Preview
I started out with the preview part, by implementing the **Preview.Comic**. The static function *comic(file:)* makes use of the Bundle decode extension to easily decode a json file into a Swift model, in this case the model **Comic**.
It is used in both **ContentView_Previews** and **DetailView_Previews**. I added a json file with an array of 20 comic json objects, for easy previewing from the xkcd web site.

## Networking
Next I googled around to find a simple solution for image loading, using the new Swift concurrency features. I have previously used AsyncImage, but wanted to avoid using external packages. I found a nice implementation at [Using Swift’s async/await to build an image loader](https://www.donnywals.com/using-swifts-async-await-to-build-an-image-loader/). I modified it a bit, mainly by commenting out the persisting the image to file after loading, which gave me an error that I at the time didn't immediately see a solution for. I thought I would come back solving this issue later if I had time. (In the last hour of the challenge, I fixed this issue.)

For the API networking I used a proven model and functions I have previously used, the *ApiClient* which uses a generic struct type that makes it very easy to directly decode json loaded from an API call directly to a Swift model. I have implemented this solution myself in my present work, just simplified it a bit for this app.

## ComicsViewModel
I always use a viewModel for implementing the networking and published variables. This makes the SwiftUI View clean and easy to read. As I makes use of the new Swift concurrency features async await, I have to be careful to make sure that I do all updating of Published variables on the main thread. For this I decorate many of the functions with the **@MainActor** attribute. When I add this attribute to a function, I make sure that all tasks in the function is performed on the main thread. Xcode gives a runtime warning in the dreaded blue color if I don't do this.

I had problems with the convenience init of the viewModel, which is used to load in the preview json from file. I found that I had to do the loading in a traditional *DispatchQueue.main.async* closure to avoid the runtime warning of implementing tasks on outside the main thread.
I am not sure if that is the right way to do it, but at least I got the warning out of the way.

## ContentView and DetailView
I made the app with two SwiftUI views, the **ContentView** which is shown when launching the app, and **DetailView** which is opened when pressing the ℹ️ button. I have used the new **NavigationStack** for pushing the detail view onto the stack, using **NavigationPath** Published variable in **ComicsViewModel**. The new navigation stack is a joy to use, compared to the old **NavigationView** and **NavigationLink**.

I landed on the design of using a search bar on the top, with two arrows below and the comic title and info button in the middle. At the bottom is the comic strip image itself. There are probably easier way to implement this, but I found out that this worked for me. I could have the two arrows for browsing the comic strips in the navigation bar, but that would be confusing when pushing a new view onto the navigation stack. I could have the detailed view as a sheet to avoid this, but anyway I found my solution to be working ok for now.

When the app is launched, the viewModel loads the **Comic** models from file, the same it does for the preview. This means the user can immediately start viewing the comic strips by tapping the right button. As there are loaded about 20 comics, the viewModel will start fetching comics using the xkcd api and then load the image when reaching the end of the array. This is made easy by using async await. Previously I would have used Combine to do this, but the new Swift concurrency is so much easier to use.

## The search bar
I wanted initially use the new token based searching that came with iOS 16, so that I could use a token for searching with number, and another token for searching with title. This would make it very cool by mimicking the way we search as used in e.g. Mail. There is a new *searchable* view modifier for this with a token parameter. As this is a completely new feature for me, I found after some struggle that it would take too much time to implement this. So I resigned to only search for comic numbers. This was much easier to implement, and the viewModel will present the comic strip image for the image as soon as a valid number is typed in the search bar. If the comic number can't be found in the comics array in the viewModel, it will try to fetch it via a network API request, add it to the comics array, and load the image with the image loader.

I also added a progress indicator that as shown instead of the comic strip title and the info button, when making a network request.

## Comix Explanation
As I understood the  task getting the comic explanation, is to present a web view that explains the comic presented. I implemented this with a UIViewRepresentable, as there is no native Web View yet in SwiftUI. I am using a full screen view modifier feature in SwiftUI to present the web view. This worked fine, the web view is showing the comic explanation site. But I also found out that I got the *"This method should not be called on the main thread as it may lead to UI unresponsiveness."* runtime warning when a web view is presented, and that is in the XComicsApp. I thought I would fix that by using a @MainActor attribute for the function that sets the flag that makes the web view appear, but I am still getting this warning. I am not sure if this is a bug in SwiftUI, or if I am missing something here.

## Favorite
I implemented favorite feature, but as I explained previously I had some problems persisting images to the file system, and as I probably will face the same problems persisting the comic json files to the file system, I for now just implemented this feature in memory. I will come back to this if I have more time.

## Sharing Comic
I added a new ToolbarItem on the trailing side of the Navigation bar for sharing comics. This was very easy in SwiftUI, it's just a one-liner in addition to the ToolbarItem statement. I first didn't understand why it didn't work, but then I came to realize that this must be run on a device that can send messages via Messages to other people, i.e. on a real device. I then tested it by sending the Comic strip I selected to my wife from my iPhone, and it worked beautiful (but my wife didn't understand what was funny by the comic strip 🤣).

## Conclusion 
The app now looks like it works fairly well. There are a few things I would like to do, but as I am now over 11 hours into the challenge, I must start to see if I can fix the most obvious missing features.

## Last minutes notes
As I am finishing the challenge, I revisited the issue of persisting the image to a file on the device. I found out that it tried to write to the *applicationSupportDirectory*, and when I replaced that with *documentDirectory*, it worked. I can now browse the comics, and when a comic strip image have been persisted to file, it reads quickly from file instead of fetching from the xkcd api. This results in a much quicker and pleasing way to browse the comics.

