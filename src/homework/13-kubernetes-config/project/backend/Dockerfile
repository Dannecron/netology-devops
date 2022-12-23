FROM python:3.9-buster

RUN mkdir /app && python -m pip install pipenv

WORKDIR /app

COPY Pipfile /app/Pipfile
COPY Pipfile.lock /app/Pipfile.lock

RUN pipenv install

COPY main.py /app/main.py

CMD pipenv run uvicorn main:app --reload --host 0.0.0.0 --port 9000
