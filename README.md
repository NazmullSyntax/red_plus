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





