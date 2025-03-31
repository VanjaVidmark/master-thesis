from flask import Flask, request
import os

app = Flask(__name__)

UPLOAD_FOLDER = '.'

@app.route('/upload', methods=['POST'])
def upload():
    filename = request.headers.get('Filename', 'no_name.txt')
    data = request.data
    if not data:
        return 'No data received', 400

    filepath = os.path.join(UPLOAD_FOLDER, filename)
    with open(filepath, 'wb') as f:
        f.write(data)

    print(f"Saved {filename}")
    return f'Data saved to {filepath}', 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5050)
