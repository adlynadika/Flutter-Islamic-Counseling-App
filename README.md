# Qalby2Heart — Islamic Counseling App

## a) Group Members
- NUR JANNAH NAI'MAH BINTI ZAINAL (2211400)
- ADLYN SOFEA BINTI MOHD ARIFF ADIKA (2214042)
- IRDINA BINTI MOHD AZMAN (2112432)

## b) Project Title
Qalby2Heart: Islamic Counseling Mobile Application

## c) Introduction
Many people experience emotional stress, anxiety, and personal challenges, but existing counseling apps often overlook spiritual and cultural needs. Muslim users, in particular, may find it difficult to access guidance that aligns with their faith while being convenient and accessible. This creates a gap for those who want counseling that supports both emotional and spiritual well-being.

To address this need, we propose **Qalby2Heart**, an Islamic counseling mobile application that will provide a safe, Shariah-compliant, and culturally sensitive platform. The app will include a _Home_ page for easy navigation, _AI Chat_ for instant guidance, _Mood Tracker_ to monitor emotions, _Resources_ for educational and spiritual content, and a _Journal_ for personal reflection. By integrating Islamic principles such as **ihsan (excellence)** and **sakinah (tranquility)**, Qalby2Heart aims to offer a meaningful alternative to conventional counseling apps, helping users manage emotional challenges while staying connected to their faith (Ismail et al., 2019).

## d) Objectives


## e) Target Users


## f) Features and Functionalities


## g) Proposed UI Mock-up


## h) Architecture / Technical Design


## i) Data Model
### Firestore Collection–Document Model

The proposed Qalby2Heart application will use **Firebase Cloud Firestore** to store user data and application content. The data model is designed to support the core features of the app, including AI Chat, Mood Tracking, Resources, and Journal.

```text
users (collection)
 └── userId (document)
     ├── name: string
     ├── email: string
     ├── role: string (user / counsellor)
     ├── createdAt: timestamp


ai_chats (collection)
 └── chatId (document)
     ├── userId: reference (users)
     ├── messages: array
     │    ├── sender: string (user / ai)
     │    ├── text: string
     │    └── timestamp: timestamp


mood_logs (collection)
 └── moodId (document)
     ├── userId: reference (users)
     ├── mood: string
     ├── note: string
     └── createdAt: timestamp


resources (collection)
 └── resourceId (document)
     ├── title: string
     ├── category: string
     ├── contentType: string (article / video / audio)
     ├── url: string
     └── createdAt: timestamp


journals (collection)
 └── journalId (document)
     ├── userId: reference (users)
     ├── title: string
     ├── content: string
     └── createdAt: timestamp
```
## j) Flowchart / Sequence Diagram


## k) References
1. Ismail, N., Hassan, S. A., & Amin, A. S. (2019). Islamic counseling: An approach to mental health and emotional well-being. IIUM Journal of Educational Studies. https://journals.iium.edu.my/ijes/index.php/iejs/article/view/399/163
