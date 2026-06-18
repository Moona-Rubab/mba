# mba

Moona Rubab
SE221040 - 8B
Mobile Application Development - Assignment #01

API Used
JSONPlaceholder — a free fake REST API for testing and prototyping.
Base URL: https://jsonplaceholder.typicode.com
Endpoint used: /posts (mapped as "Courses" in this app)
Documentation Followed
https://jsonplaceholder.typicode.com/guide

Branch 1:
feature/course-api-integration
Branch 2:
feature/offline-cache-and-state-manangement

Architecture Explanation:
UI Screens  (courses_screen, add_edit_course_screen)
      ↓  context.watch / context.read
CourseProvider  (ChangeNotifier — manages loading/success/error/empty states)
      ↓  calls repository methods
CourseRepository  (decides: API or Hive?)
      ↓                    ↓
CourseService          Hive Box
(HTTP only)            (local disk storage)
      ↓
JSONPlaceholder API


Tools and Packages Used:

This project uses four packages. The provider package (version 6.1.2) handles state management and replaces the manual setState callback pattern used in Part 2. The hive_flutter package (version 1.1.0) provides local storage and caches course data on the device so the app works offline. The connectivity_plus package (version 6.0.3) detects whether the device has an active internet connection, which the repository uses to decide between fetching from the API or loading from local cache. The http package (version 1.2.0) carries over from Part 2 and handles all HTTP requests to the JSONPlaceholder API.


"Offline Support Explanation"

When fetchCourses() is called:
connectivity_plus checks if the device has internet
Online → fetch from JSONPlaceholder API → save to Hive → display
Offline → load from Hive → display with orange offline banner
Create, Update, and Delete require an internet connection — an error message is shown if attempted offline.


State Management Explanation
CourseProvider extends ChangeNotifier and manages four states. When the state is loading, the UI shows a spinner with the message "Fetching courses...". When the state is success, the UI shows the full course list with the search bar. When the state is error, the UI shows an error message along with a Retry button. When the state is empty, the UI shows an empty state illustration with a message to add a course.

following are the screenshots:


![alt text](</screenshots/Registration Page.png>)

![alt text](</screenshots/Login page.png>)

![alt text](</screenshots/Dashboard Page.png>)

![alt text](</screenshots/Subject Details Page.png>)

![alt text](</screenshots/dashboard screen.png>)

![alt text](</screenshots/courses screen.png>)

![alt text](</screenshots/add course.png>)

![alt text](</screenshots/update course.png>)

![alt text](</screenshots/delete course.png>)