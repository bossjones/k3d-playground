# app.py
from flask import Flask

app = Flask(__name__)

@app.route('/')
def hello_docker():
    """_summary_

    Returns:
        _type_: _description_
    """
    return '<h1> hello world </h1'

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')
