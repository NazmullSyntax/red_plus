🩸 Red Plus (Red+) — Blood Donation Application
Red Plus is a real-time mobile application designed to bridge the gap between blood donors and recipients in need, streamlining the process of emergency blood request and donor management.
Key Features & ModulesUser:
Authentication & Account Management:
# Secure user signup and authentication using email and password.
* Profile creation with user details, location, and blood group specification ($A^+$, $A^-$, $B^+$, $B^-$, $AB^+$, $AB^-$, $O^+$, $O^-$).
* Donor availability toggle status (Available / Unavailable).
# Blood Request & Donor Matching System:
* Emergency blood request creation with location tagging and urgency levels.

* Location-based donor matching algorithm to connect patients with nearby compatible donors.

* Filter and search tools to quickly find eligible blood donors by group and area.
# Notifications & Interactive Feed:
* Active feed displaying real-time urgent blood requests.
* Push notification system alerting eligible donors whenever an emergency request is posted nearby.
# Communication & Donor Tracking:
* In-app contact tools allowing requesters to directly reach out to donors via call or message.
* Donation history tracker calculating donor cooldown periods and next eligible donation dates.

2. Description of main projects
System Architecture Overview
<img width="5814" height="8192" alt="Blood Donation Request Flow-2026-07-22-205233" src="https://github.com/user-attachments/assets/f801f461-7dbd-4756-8626-ab02ac7a7884" />

Application Workflow Diagram
<img width="8192" height="2491" alt="wk" src="https://github.com/user-attachments/assets/4aa733d1-42db-480a-a4d8-27c6c54977ad" />

Technology Stack::

<img width="764" height="497" alt="tech" src="https://github.com/user-attachments/assets/95dde4f1-509a-4b72-beab-684df7c270fd" />

Database Schema Structure::

users Collection


{
  "uid": "STRING (Primary Key)",
  "fullName": "STRING",
  "email": "STRING",
  "phone": "STRING",
  "bloodGroup": "STRING (e.g. O+)",
  "location": "GEOPOLYGON / STRING",
  "isDonor": "BOOLEAN",
  "lastDonationDate": "TIMESTAMP"
}

requests Collection:


{
  "requestId": "STRING (Primary Key)",
  "requesterId": "STRING (Foreign Key -> users.uid)",
  "patientName": "STRING",
  "bloodGroupNeeded": "STRING",
  "unitsNeeded": "INTEGER",
  "hospitalName": "STRING",
  "status": "STRING (Pending / Fulfilled / Cancelled)",
  "createdAt": "TIMESTAMP"
}

# Main Gateway Dashboard for RedPulse.


<img width="775" height="1599" alt="hm" src="https://github.com/user-attachments/assets/5aa5b512-1dd8-47d7-8a6b-6c62a1e4e7c7" />

* Smart Routing: Directs users into two distinct workflows—"Continue as a Donor" (to view requests and donate) or "Continue as a Patient" (to request blood).
* Live Status: The LIVE pulse indicator confirms real-time connection to active blood requests.

Personalized UX: Features dynamic user greetings and an interactive health-tip carousel to boost engagement.


# User Profile Dashboard (My Profile) for RedPulse.


<img width="791" height="1600" alt="pf" src="https://github.com/user-attachments/assets/428bca08-df51-4225-a175-fb6d4532e18c" />


Key Components & Functions
* User Identity Card: Displays the user's avatar (with an edit shortcut), full name (Ahmed Emon), role tag (DONOR), email, and contact number.
* Quick Health & App Stats:

Blood Group: Displays donor blood type (O+).

Status: Shows current availability (Active).

Joined Year: Tracks membership history (2024).

* Settings Navigation: Quick access links to Edit Profile, Notifications, Privacy & Security, and Help & Support.

# Emergency Blood Request / Send SOS Screen for RedPulse.

<img width="785" height="1600" alt="so" src="https://github.com/user-attachments/assets/15b28946-d1fb-43d3-90c3-cbe463638620" />

Header: Prominently marked as "Emergency Blood Request" to highlight high urgency.

Input Fields:

Blood Type (*): Dropdown to select the required blood group (e.g., A+, O-).

Need (*): Dropdown to specify required units or components (e.g., Whole Blood, Platelets).

Location (*): Area/city selection for geo-targeting nearby donors.

Hospital (*): Target medical facility where blood is needed.

Phone Number (*): Contact details for direct communication.

Call-To-Action: "Send SOS Now" button triggers instant push notifications/alerts to all active matching donors in the selected area.


# SOS Requests Feed / Donor Response Screen for RedPulse

<img width="791" height="1600" alt="sd" src="https://github.com/user-attachments/assets/4775be21-bf0d-4f68-9637-1fa1f2f7c4e9" />

Live Feed & Refresh: Displays active emergency blood requests in real-time, with a top-right refresh button to update the list.

Request Cards Detail:

Patient/Requester Info: Shows who requested the blood (e.g., Rajwan Ahamed, Fahim).

Required Blood Group: Highlighted blood type needed (e.g., A-, B+).

Hospital Location: Specific location and facility (e.g., Uttara, Ibn Sina Uttara).

Time Elapsed: Time since the SOS was issued (e.g., 51 minutes ago).

Response Tracker: Shows how many donors have already responded (e.g., RESPONSES: 1).

Action Shortcuts:

Responded Button: Indicates the user has already opted in to respond to this request.

Message Icon (Blue): In-app chat button to communicate directly with the requester.

Call Icon (Green): Quick action button to initiate a direct phone call to the requester.

# lets see our first demo project live videw in one shot 


https://github.com/user-attachments/assets/39824158-8009-4fc1-b4b7-47d7614ffc5f

# well in the first demo project there are some ui or ux desiagn problem we have see then we apply the new theme hope all people except it 
now see our final project in one click 


https://github.com/user-attachments/assets/7e475287-71bd-4183-8546-75ca82ba04d6












