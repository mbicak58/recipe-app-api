FROM python:3.9-alpine3.22
 
# Use the latest Alpine Linux image with Python 3.9

LABEL maintainer=""

ENV PYTHONUNBUFFERED=1

# Ensure that Python output is sent straight to terminal (e.g., your container log) without being buffered

COPY ./requirements.txt /tmp/requirements.txt 
COPY ./requirements.dev.txt /tmp/requirements.dev.txt 
# Copy the development requirements file into the image
#Copy the requirements file into the image
COPY ./app /app 
# Copy the application code into the image
WORKDIR /app 
# Set the working directory to /app
EXPOSE 8000 
# Expose port 8000 for the application

ARG DEV=false 
# Define a build argument to control the installation of development dependencies / dev mode
RUN python -m venv /py && \
# Create a virtual environment in /py
    /py/bin/pip install --upgrade pip && \ 
    apk add --update --no-cache postgresql-client && \
    # we installed the postgresql client inside our alpine image, to connect
    apk add --update --no-cache --virtual .tmp-build-deps \
    # it sets a virtual dependencies package
        build-base postgresql-dev musl-dev python3-dev && \
    # Upgrade pip in the virtual environment
    /py/bin/pip install -r /tmp/requirements.txt && \ 
    # Install the dependencies from the requirements file
    if [ $DEV = 'true' ]; \
        then /py/bin/pip install -r /tmp/requirements.dev.txt ; \ 
    fi && \ 
    # If DEV is true, install development dependencies
    rm -rf /tmp && \ 
    # Remove the temporary requirements file
    apk del .tmp-build-deps && \
    # it removes the files in line 31
    adduser \ 
    # Create a non-root user to run the application
        --disabled-password \ 
        # Disable password login
        --no-create-home \ 
        # Do not create a home directory
        django-user 
        # Name of the user
    
ENV PATH="/py/bin:$PATH" 
# Add the virtual environment's bin directory to the PATH

USER django-user 
# Run the application as the non-root user


# Create a virtual environment, upgrade pip, install dependencies, and clean up pip cache   