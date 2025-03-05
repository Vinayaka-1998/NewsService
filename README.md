NewsService iOS - Developer Documentation
Overview
NewsService is an iOS application that fetches and displays the latest U.S. Top Headlines. The project does not use any third-party dependencies and is built using UIKit and Swift.

Developers can clone or download the project from the main branch.
Features
* User Authentication: Users must enter a valid API key to access the news feed.
* News List: Displays the latest U.S. top headlines in a table view.
* Web View Integration: Each news item contains a link that can be opened in a web page.
* Detail View Navigation: Users can tap on a news item to navigate to a detailed screen.
* Error Handling: Alerts users if the source ID is missing or if API authentication fails.
Authentication Flow
1. Login Screen:
    * Users enter their name and API key.
    * The API key is validated by making a request to the server.
    * If the API key is invalid, a 401 error is received, and an error message is displayed.
    * On successful validation, the user is redirected to the news list screen.
News List Screen
* Displays a list of top U.S. headlines.
* Each cell contains:
    * News title
    * News source
    * Published date
    * Link to full article
Actions
* Tap on Web Link: Opens the article in a web view.
* Tap on a News Cell:
    * If sourceId is present, navigates to the Detail Screen.
    * If sourceId is missing, an alert appears with the message: Details not found.

How to Run the Project
1. Clone the repository: git clone https://github.com/Vinayaka-1998/NewsService.git
2. Open NewsService.xcodeproj in Xcode.
3. Build and run the app on a simulator or a physical device.
Error Handling
Error Code	Description
401	Invalid API key. User must enter a valid key.
404	News article not found.
No Source ID	Displays an alert: Details not found.
Conclusion
This project serves as a simple news app that validates API keys before fetching news data. It follows a clean navigation flow and ensures smooth user interaction. Feel free to extend the functionality or integrate additional features!
For any issues, refer to the GitHub repository or contact the project maintainer.
