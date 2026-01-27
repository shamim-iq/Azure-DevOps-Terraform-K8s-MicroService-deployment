from flask import Flask, jsonify

app = Flask(__name__)

@app.route("/health")
def health():
    return jsonify(status="UP")

@app.route("/api/message")
def message():
    return jsonify(message="Hello from Backend API")

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
