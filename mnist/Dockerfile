#This container contains your model and any helper scripts specific to your model.
FROM tensorflow/tensorflow:1.15.2-py3

ADD src/app.py /opt/model.py
RUN chmod +x /opt/model.py

ENTRYPOINT ["/usr/local/bin/python"]
CMD ["/opt/model.py"]