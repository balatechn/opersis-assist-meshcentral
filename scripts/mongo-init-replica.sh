#!/bin/bash
# ============================================================================
# MongoDB Replica Set Initialization
# Required for MeshCentral change streams functionality
# ============================================================================

echo "🗄️  Initializing MongoDB Replica Set..."

# Wait for MongoDB to be ready
sleep 5

# Initialize replica set
mongosh --quiet --eval "
try {
  rs.status();
  print('✅ Replica set already initialized');
} catch(e) {
  rs.initiate({
    _id: 'rs0',
    members: [
      { _id: 0, host: 'mongodb:27017' }
    ]
  });
  print('✅ Replica set initialized successfully');
}
"

echo "🗄️  MongoDB Replica Set ready!"
