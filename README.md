# Flutter Islamic Counseling App

📱 A cross‑platform mobile app offering faith‑based counseling, resources, and AI‑powered chat support.  
Built with **Flutter** and **Firebase**, designed for accessibility and modern UI/UX.

---

## 🤖 AI Chat Demo
![AI Chat Demo](/demo/AI%20Chat%20Demo.gif)

---

## ✨ Features
- AI‑powered chat for counseling guidance
- Counseling sessions guided by Islamic principles
- Knowledge resources and Qur’anic references
- Secure Google Sign‑In authentication
- Light/Dark mode UI

---

## 🛠 Tech Stack
![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![OpenRouter](https://img.shields.io/badge/OpenRouter-000000?style=for-the-badge&logo=openai&logoColor=white)


---

## ⚙️ Technical Details (AI Chat)
- Integrated **OpenRouter API** for AI responses.  
- Model used: **AllenAI: Molmo2 8B (free)**.  
- API key stored securely in `.env` (excluded via `.gitignore`).  
- Example request:
  ```dart
  final response = await http.post(
    Uri.parse("https://openrouter.ai/api/v1/chat/completions"),
    headers: {
      "Authorization": "Bearer $apiKey",
      "Content-Type": "application/json",
    },
    body: jsonEncode({
      "model": "allenai/molmo2-8b",
      "messages": [
        {"role": "system", "content": "You are an Islamic counseling assistant."},
        {"role": "user", "content": userMessage},
      ],
    }),
  );
