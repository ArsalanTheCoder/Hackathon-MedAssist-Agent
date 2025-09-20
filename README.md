# 🏥 MedAssist Agent — Internet of Agents (Nexamind Team)

✨ An AI-powered medical assistant built for the *Internet of Agents* Hackathon.  
Smart, multi-agent healthcare companion for symptom checking, doctor finding, pharmacy lookup, emergency help, and more.

---

## 🌟 Overview
MedAssist Agent leverages multi-agent collaboration and LLMs to help patients and healthcare providers with:
- Symptom checking & medical guidance  
- Medication reminders & doctor contact  
- Emergency calls & directions  
- Trusted medical information and quick consultation links

---

## 🔗 Key Features
- 🧠 AI-driven medical insights  
- 🤖 Multi-agent system (SymptomAgent, InfoAgent, ReminderAgent, etc.)  
- 📱 Clean conversational UI with intuitive flows  
- ✅ Fact-checker integration to improve response reliability

---

## 📸 Screenshots (aligned per your request)

<!-- Row 1: Screenshots 1 & 2 (prominent) -->
<p align="center">
  <img src="https://github.com/user-attachments/assets/cc2bb62b-62c0-44da-bfdc-bb65fa57413f" width="420" alt="01 - Dashboard: main options" style="margin:8px;">
  <img src="https://github.com/user-attachments/assets/6a1a4906-6a4c-4fff-984e-79f02b68fb89" width="420" alt="02 - Emergencies list" style="margin:8px;">
</p>
<p align="center"><em>Dashboard (check symptoms, find doctor, pharmacy, emergency) • Emergencies list with call & directions</em></p>

<!-- Row 2: Screenshots 3 → 7 (five images, medium size) -->
<p align="center">
  <img src="https://github.com/user-attachments/assets/0f09599d-cc02-4ee3-b8a6-e49203022afa" width="260" alt="03 - User input screens (1)">
  <img src="https://github.com/user-attachments/assets/6815793e-5e18-426c-aeb5-b3ba69f95f95" width="260" alt="04 - User input screens (2)">
  <img src="https://github.com/user-attachments/assets/b65c84d8-ad89-4994-8316-b561c46323ce" width="260" alt="05 - User input screens (3)">
  <img src="https://github.com/user-attachments/assets/dc73645a-d3af-41df-a9ad-389672e432d1" width="260" alt="06 - Direct consultation link">
  <img src="https://github.com/user-attachments/assets/518d064b-8932-44fb-8fe1-e60600566d63" width="260" alt="07 - Profile screen">
</p>
<p align="center"><em>Input & conversational screens • Direct doctor consultation link • Profile</em></p>

<!-- Row 3: Screenshots 9 → 13 (payment & remaining screens, compact) -->
<p align="center">
  <img src="https://github.com/user-attachments/assets/dd52e8b6-561d-4a9c-a65c-5bf06d56bbd2" width="220" alt="09 - Solana payment UI (1)" style="margin:6px;">
  <img src="https://github.com/user-attachments/assets/e001075a-07a4-436d-a15d-a1fc5b19f239" width="220" alt="10 - Future work / placeholder" style="margin:6px;">
  <img src="https://github.com/user-attachments/assets/d4ae6a72-e0e2-4776-a156-05a11ba82970" width="220" alt="11 - Additional screen" style="margin:6px;">
  <img src="https://github.com/user-attachments/assets/cf268965-4a61-4274-bc3a-df82af8f188d" width="220" alt="12 - Additional screen" style="margin:6px;">
  <img src="https://github.com/user-attachments/assets/2a517374-7758-407f-8c45-2052a132b2e7" width="220" alt="13 - Additional screen" style="margin:6px;">
</p>
<p align="center"><em>Solana payment UI & other supporting screens</em></p>

---

## 🏗 Architecture
```mermaid
flowchart TD
    A[👩‍⚕ User Input] --> B[🧠 Orchestrator Agent]
    B --> C[👁 Symptom Checker Agent]
    B --> D[📚 Medical Info Agent]
    B --> E[⏰ Emergency Call Agent]
    B --> F[✅ Pharmacy Finder Agent]
    C --> G[📋 Diagnosis Suggestions]
    D --> G
    E --> G
    F --> G
    G --> H[💬 User Response]
    H --> I[🏷 Nexamind Team & Project Status]
    I --> J[⚠️ Notes: Project completed UI & backend; failed to register agent on Coral server; unable to submit final hackathon task due to Coral issues]
