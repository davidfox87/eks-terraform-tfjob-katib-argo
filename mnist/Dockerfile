#This container contains your model and any helper scripts specific to your model.
FROM tensorflow/tensorflow:latest

COPY requirements.txt requirements.txt

RUN pip3 install -r requirements.txt

ADD src/app.py /opt/model.py
RUN chmod +x /opt/model.py

ENTRYPOINT ["/usr/local/bin/python"]
CMD ["/opt/model.py"]