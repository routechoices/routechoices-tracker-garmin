FROM kalemena/connectiq:latest

#ADD developer_key.der /developer_key.der

RUN mkdir -p app/
WORKDIR app/
#ADD . app/

# docker run -it --rm -v /home/rphl/Projects/GarminRoutechoicesTracker/:/home/developer/app/ --privileged routechoicestracker:v1 bash
# monkeyc --jungles monkey.jungle --device fr235 --output bin/routechoicesTracker-fr235.prg --private-key developer_key.der --warn
CMD ["monkeyc --jungles app/monkey.jungle --package-app --release --output /tmp/routechoicesTracker.iq --private-key app/developer_key.der --warn"]