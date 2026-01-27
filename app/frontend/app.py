from flask import Flask
import requests
import os

app = Flask(__name__)

BACKEND_URL = os.getenv("BACKEND_URL", "http://backend-service:5000")

@app.route("/")
def home():
    try:
        response = requests.get(f"{BACKEND_URL}/api/message")
        return f"""
                <div style="
                background-color:#000000;
                height:100vh;
                display:flex;
                flex-direction:column;
                justify-content:center;
                align-items:center;
                ">
                <div style="
                    width:120px;
                    height:18px;
                    background-color:#ffc000;
                    margin-bottom:10px;
                    transform:skewX(-20deg);
                "></div>

                <h1 style="
                    color:#ffffff;
                    font-size:72px;
                    font-family:Arial, Helvetica, sans-serif;
                    margin:0;
                ">
                    EY
                </h1>

                <p style="color:#ffffff; margin-top:20px;">
                    {response.json()['message']}
                </p>
                </div>
                """
    except Exception as e:
        return f"Backend not reachable: {str(e)}"

@app.route("/health")
def health():
    return "OK"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
