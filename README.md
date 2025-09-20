# 🏥 MedAssist Agent  

✨ An AI-powered 🧠 medical assistant 🤖💉 built for the *Internet of Agents 🌐 Hackathon 🚀*  

---

## 🌟 Overview  
MedAssist Agent is designed to *revolutionize healthcare assistance* by leveraging the power of *multi-agent systems* and *LLMs (Large Language Models)*.  
It serves as a smart companion for patients and healthcare providers by:  
- 📋 Assisting in *symptom checking & health guidance*  
- 💊 Providing *medication reminders*  
- 📞 Helping with *doctor-patient communication*  
- 🔎 Offering *trusted medical information* from reliable sources  

---

## 🔗 Key Features  
- 🧠 *AI-driven Medical Insights* – Understands and analyzes user queries  
- 🤖 *Multi-Agent Collaboration* – Specialized agents work together (SymptomAgent, InfoAgent, ReminderAgent, etc.)  
- 📱 *User-Friendly Interface* – Simple, conversational, and accessible  
- ✅ *Fact-Checker Integration* – Ensures accuracy & reliability of medical responses  

---

## 🏗 Architecture  
```mermaid
flowchart TD
    A[👩‍⚕ User Input] --> B[🧠 Orchestrator Agent]
    B --> C[👁 Symptom Checker Agent]
    B --> D[📚 Medical Info Agent]
    B --> E[⏰ Emergency Call]
    B --> F[✅ Pharmacy Finder]
    C --> G[📋 Diagnosis Suggestions]
    D --> G
    E --> G
    F --> G
    G --> H[💬 User Response]
