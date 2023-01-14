# developer-training

Steps to initiate this project:

1) Install Docker Desktop
2) In your terminal CD into the `Node-Red-Intro/` directory and build the Dockerfile.
    - docker build -t node-red-intro:latest .
3) Once the build is finished run the Dockerfile.
    - `docker run --rm -e "NODE_RED_CREDENTIAL_SECRET=your_secret_goes_here" -p 1880:1880 -v $(pwd):/data --name node-red node-red-intro:latest`
        - put whatever you want for `your_secret_goes_here`
    - If that works you will see running logs in the terminal...
4) Finally go to http://localhost:1880/ in your web browser (I think Chrome works best)
