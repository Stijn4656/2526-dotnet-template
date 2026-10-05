node {
    stage('Checkout') {
        checkout scm
    }
    stage('Preparation') {
        // remove the previous deployment; "|| true" = don't fail when nothing is there yet
        sh 'docker rm -f riseapp risedb || true'
        sh 'docker network create rise-net || true'
    }
    stage('Database') {
        // PostgreSQL instead of the template's default SQLite file
        sh '''
            docker run -d --name risedb --network rise-net \
              -e POSTGRES_DB=rise -e POSTGRES_USER=rise -e POSTGRES_PASSWORD=rise \
              postgres:17
            until docker exec risedb pg_isready -U rise -d rise; do sleep 2; done
        '''
    }
    stage('Build') {
        sh 'docker build -t riseapp .'
    }
    stage('Deploy') {
        // Development: the app only runs its EF Core migrations and seeder in Development (see Program.cs)
        sh '''
            docker run -d --name riseapp --network rise-net -p 8082:8080 \
              -e ASPNETCORE_ENVIRONMENT=Development \
              -e "ConnectionStrings__DatabaseConnection=Host=risedb;Port=5432;Database=rise;Username=rise;Password=rise" \
              riseapp
        '''
    }
    stage('Smoke test') {
        // migrations + seeding take a few seconds on the first start: retry for up to 60 s
        sh '''
            for i in $(seq 1 30); do
              curl -sf http://172.16.0.10:8082/ > /dev/null && { echo "App is up"; exit 0; }
              sleep 2
            done
            docker logs --tail 30 riseapp
            exit 1
        '''
    }
}
