#This container contains your model and any helper scripts specific to your model.
FROM tensorflow/tensorflow:latest-py3
LABEL maintainer="david.fox@dish.com"

COPY requirements.txt requirements.txt

RUN pip3 install -r requirements.txt

ADD src/app.py /opt/model.py
RUN chmod +x /opt/model.py

EXPOSE 6006

#ENTRYPOINT ["/usr/local/bin/python3"]
CMD ["python3 /opt/model.py"]