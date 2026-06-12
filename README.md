# TimeTracker

Tracks your working time and reminds you to incorporate standing and moving into your workday.

## Features

- Start focus sessions in certain intervals. After the time completes, you receive a notification to stand up for a certain amount of time, depending on how long you sat. After that, you receive a second notification to move for a few minutes. This is the perfect time to refill your drink, catch a breath of fresh air or do something else. The short time of, will replenish your energy and keep you focused. So you are able to do more tasks, with better outcomes, all while keeping your body healthy.

## Installation

The installation process is simple, but slightly diverges from the usual Mac installation process.

1. Go to the Releases page and download the latest version of the app.
2. Unzip the file.
3. Move the app to your Applications folder.
4. Mark the application as non-quarantined via `xattr -dr com.apple.quarantine /Applications/TimeTracker.app`. This step is crucial, otherwise the application is marked as quarantined and untrustworthy, and thus can't be opened.

## Q&A

Q: Why is the app marked as quarantined?
A: The app is marked as quarantined because it is not signed with a valid certificate. A valid certificate can be obtained by signing the app with your Apple Developer Account. An Apple Developer account costs 100€ a year, which I am not willing to pay for a simple side project.
