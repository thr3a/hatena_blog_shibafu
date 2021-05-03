gcloud auth print-access-token | docker login -u oauth2accesstoken --password-stdin https://asia.gcr.io
APP_NAME=hatena-blog-shibafu
docker build -t asia.gcr.io/virtual-machines-156321/${APP_NAME}:latest .
docker push asia.gcr.io/virtual-machines-156321/${APP_NAME}:latest
gcloud beta run deploy ${APP_NAME} \
  --image asia.gcr.io/virtual-machines-156321/${APP_NAME}:latest \
  --region=asia-northeast1 \
  --allow-unauthenticated \
  --port=9292 \
  --cpu=1 --memory=512Mi --max-instances=1 \
  --platform managed
