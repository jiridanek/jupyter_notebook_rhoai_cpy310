# Use the official Python 3.10.9 base image
FROM python:3.10.9

USER 1001:0
ENV APP_ROOT=/opt/app-root
# https://pipenv.pypa.io/en/latest/virtualenv.html#renaming-or-moving-a-project-folder-managed-by-pipenv
ENV PIPENV_VENV_IN_PROJECT=true
ENV VIRTUAL_ENV=${APP_ROOT}/.venv
# OpenShift Ai will mount a PVC to this location when workbench starts
ENV HOME=${APP_ROOT}/src

# Set the working directory
WORKDIR ${APP_ROOT}

# https://docs.openshift.com/container-platform/4.16/openshift_images/create-images.html#use-uid_create-images
RUN chgrp -R 0 ${APP_ROOT} && \
    chmod -R g=u ${APP_ROOT}

# Copy the Pipfile and Pipfile.lock
COPY --chown=1001:0 Pipfile Pipfile.lock ./

# Install pipenv
RUN python3.10 -m pip install --user pipenv

# Install the dependencies from Pipfile
RUN python3.10 -m pipenv install --deploy --ignore-pipfile && \
# and fix the perms again for the newly added files
    chgrp -R 0 ${APP_ROOT} && \
    chmod -R g=u ${APP_ROOT}

# Expose the Jupyter Notebook port
EXPOSE 8888

# Trick from https://github.com/sclorg/s2i-python-container/blob/master/3.11/Dockerfile.c9s#L79
# to activate venv when image is started

# The following echo adds the unset command for the variables set below to the \
# venv activation script. This is inspired from scl_enable script and prevents \
# the virtual environment to be activated multiple times and also every time \
# the prompt is rendered. \
RUN echo "unset BASH_ENV PROMPT_COMMAND ENV" >> ${VIRTUAL_ENV}/bin/activate
# For Fedora scl_enable isn't sourced automatically in s2i-core
# so virtualenv needs to be activated this way
ENV BASH_ENV="${VIRTUAL_ENV}/bin/activate" \
    ENV="${VIRTUAL_ENV}/bin/activate" \
    PROMPT_COMMAND=". ${VIRTUAL_ENV}/bin/activate"

# Command to run Jupyter Notebook
COPY --chown=1001:0 start-notebook.sh ./
ENTRYPOINT ["/opt/app-root/start-notebook.sh"]
