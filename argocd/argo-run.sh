export GIT_PWD=$(aws secretsmanager get-secret-value --secret-id GITHUB_PAT | jq -r '.SecretString | fromjson | .PAT ')
export GIT_USERNAME=$(aws secretsmanager get-secret-value --secret-id GITHUB_PAT | jq -r '.SecretString | fromjson | .USERNAME ')

envsubst < ./argocd/repository.yaml | kubectl apply -f -
envsubst < ./argocd/application.yaml | kubectl apply -f -