FROM locustio/locust

# シナリオ
COPY ./scripts/ /scripts/

EXPOSE 8089
EXPOSE 5557
EXPOSE 5558
