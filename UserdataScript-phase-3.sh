#!/bin/bash
set -x  # Print commands but don't exit on error
exec > >(tee /var/log/user-data.log) 2>&1
echo "=== User data script started at $(date) ==="

# Update and install required packages
apt update -y
apt install -y nodejs unzip wget npm mysql-client jq awscli net-tools

# Download and extract application code
wget https://aws-tc-largeobjects.s3.us-west-2.amazonaws.com/CUR-TF-200-ACCAP1-1-91571/1-lab-capstone-project-1/code.zip -P /home/ubuntu
cd /home/ubuntu
unzip code.zip -x "resources/codebase_partner/node_modules/*"
cd resources/codebase_partner

# Install Node.js dependencies
echo "=== Installing Node.js dependencies ==="
npm install
npm install aws-sdk aws

# Get database credentials from Secrets Manager
SECRET_JSON=$(aws secretsmanager get-secret-value --secret-id Mydbsecret --region us-east-1 --query SecretString --output text)
export APP_DB_HOST=$(echo $SECRET_JSON | jq -r '.host')
export APP_DB_USER=$(echo $SECRET_JSON | jq -r '.user')
export APP_DB_PASSWORD=$(echo $SECRET_JSON | jq -r '.password')
export APP_DB_NAME=$(echo $SECRET_JSON | jq -r '.db')

# Wait for RDS to be available
echo "=== Waiting for RDS to be available (180 seconds) ==="
sleep 180

# Test database connectivity first
echo "=== Testing database connectivity ==="
for i in {1..10}; do
    if mysql -h "$APP_DB_HOST" -u "$APP_DB_USER" -p"$APP_DB_PASSWORD" -e "SELECT 1;" > /dev/null 2>&1; then
        echo "=== Database connection successful ==="
        break
    else
        echo "=== Attempt $i: Database not ready yet, waiting 20 seconds... ==="
        sleep 20
    fi
done

# Create the students table if it doesn't exist
echo "=== Creating students table ==="
mysql -h "$APP_DB_HOST" -u "$APP_DB_USER" -p"$APP_DB_PASSWORD" "$APP_DB_NAME" <<'EOSQL'
CREATE TABLE IF NOT EXISTS students(
    id INT NOT NULL AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    address VARCHAR(255) NOT NULL,
    city VARCHAR(255) NOT NULL,
    state VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(100) NOT NULL,
    PRIMARY KEY (id)
);
EOSQL

if [ $? -eq 0 ]; then
    echo "=== Table created successfully ==="
    # Verify table was created
    mysql -h "$APP_DB_HOST" -u "$APP_DB_USER" -p"$APP_DB_PASSWORD" "$APP_DB_NAME" -e "SHOW TABLES;" 2>&1
else
    echo "=== WARNING: Table creation failed, but continuing... ==="
fi

# Start the application
echo "=== Starting application on port 80 ==="
export APP_PORT=80
nohup npm start > /var/log/webapp.log 2>&1 &
echo "=== Application started with PID $! ==="

# Wait a moment to ensure it started
sleep 5

# Check if something is listening on port 80
if netstat -tlnp | grep -q ':80'; then
    echo "=== SUCCESS: Application is listening on port 80 ==="
else
    echo "=== WARNING: Nothing listening on port 80 yet ==="
fi

echo "=== User data script completed at $(date) ==="
