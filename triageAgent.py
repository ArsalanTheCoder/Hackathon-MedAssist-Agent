# agents/triageAgent.py
import os
import json
import re
from flask import Flask, request, jsonify
from dotenv import load_dotenv
from pathlib import Path

# --- Load environment variables from project root .env ---
project_root = Path(__file__).resolve().parent.parent  # one level up from /agents
load_dotenv(project_root / ".env")

# Try importing Google Generative AI client
try:
    import google.generativeai as genai
except Exception as e:
    raise RuntimeError(
        "Could not import google.generativeai. "
        "Install it with: pip install google-generative-ai\n"
        f"Original error: {e}"
    )

# --- Configuration from environment ---
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY") or os.getenv("GOOGLE_API_KEY")
MODEL_NAME = os.getenv("MODEL_NAME", "gemini-1.5")
PORT = int(os.getenv("TRIAGE_PORT", "9001"))

if not GEMINI_API_KEY:
    raise RuntimeError("No GEMINI_API_KEY found. Check your .env file!")

# Configure GenAI client
genai.configure(api_key=GEMINI_API_KEY)

# --- Flask app setup ---
app = Flask(__name__)

# Red flag symptoms
RED_FLAGS = [
    "difficulty breathing", "shortness of breath", "chest pain", "severe bleeding",
    "unconscious", "fainting", "sudden weakness", "slurred speech", "confused",
    "loss of consciousness", "severe allergic reaction", "unable to wake"
]

def has_red_flag(text: str):
    t = text.lower()
    for flag in RED_FLAGS:
        if flag in t:
            return True, flag
    return False, None

# --- Prompt template ---
PROMPT_TEMPLATE = """
You are a medical triage assistant. Given a patient's symptom description, return a JSON object ONLY (no extra words)
with these keys:

- urgency: one of "EMERGENCY", "MODERATE", or "LOW".
- possible_conditions: an array of short condition names (2-4 items max).
- recommended_actions: a short list chosen from: ["emergency","pharmacy","consult_doctor","self_care"].
- explanation: one or two short sentences explaining the reasoning.

If unsure, choose "MODERATE". If immediate danger, choose "EMERGENCY".

Patient symptoms:
\"\"\"{symptoms}\"\"\"

Respond with valid JSON only.
"""

# --- Gemini call wrapper ---
def call_gemini_generate(symptoms: str) -> str:
    prompt = PROMPT_TEMPLATE.format(symptoms=symptoms)
    response = genai.generate_text(
        model=MODEL_NAME,
        prompt=prompt,
        temperature=0.0,
        max_output_tokens=400,
    )
    text = getattr(response, "text", None) or str(response)
    return text

def extract_json_from_text(text: str):
    match = re.search(r'\{.*\}', text, re.S)
    if match:
        try:
            return json.loads(match.group(0))
        except Exception:
            pass
    try:
        return json.loads(text)
    except Exception:
        return None

# --- API route ---
@app.route("/triage", methods=["POST"])
def triage():
    payload = request.get_json(force=True)
    text = payload.get("text", "").strip()
    if not text:
        return jsonify({"error":"no text provided"}), 400

    # Step 1: check red flags first
    red, reason = has_red_flag(text)
    if red:
        return jsonify({
            "urgency": "EMERGENCY",
            "possible_conditions": [],
            "recommended_actions": ["emergency"],
            "explanation": f"Immediate red-flag detected: {reason}. Call emergency services."
        })

    # Step 2: call Gemini
    try:
        raw = call_gemini_generate(text)
        print("RAW MODEL OUTPUT:", raw)  # debug
    except Exception as e:
        print("Gemini call failed:", e)
        return jsonify({
            "urgency":"MODERATE",
            "possible_conditions": [],
            "recommended_actions":["pharmacy","consult_doctor"],
            "explanation": "Triage unavailable; please seek care if symptoms worsen."
        })

    # Step 3: parse JSON
    parsed = extract_json_from_text(raw)
    if not parsed:
        return jsonify({
            "urgency":"MODERATE",
            "possible_conditions": [],
            "recommended_actions":["pharmacy","consult_doctor"],
            "explanation":"Could not parse model output. Please consult a healthcare provider if concerned."
        })

    # Normalize
    urgency = parsed.get("urgency","MODERATE").upper()
    if urgency not in ("EMERGENCY","MODERATE","LOW"):
        urgency = "MODERATE"
    possible_conditions = parsed.get("possible_conditions", [])
    if not isinstance(possible_conditions, list):
        possible_conditions = [str(possible_conditions)]
    recommended_actions = parsed.get("recommended_actions", [])
    if not isinstance(recommended_actions, list):
        recommended_actions = [str(recommended_actions)]
    explanation = parsed.get("explanation", "")

    return jsonify({
        "urgency": urgency,
        "possible_conditions": possible_conditions,
        "recommended_actions": recommended_actions,
        "explanation": explanation
    })

# --- Run server ---
if __name__ == "__main__":
    print(f"Starting triage_agent on port {PORT}, model={MODEL_NAME}")
    app.run(host="0.0.0.0", port=PORT)
