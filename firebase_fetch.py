import firebase_admin
from firebase_admin import credentials, db
import json
import os
from datetime import datetime

# Configuration
output_dir = r"C:\Users\Akos\Desktop\Backup"  # Output folder for backups
max_backups = 3  # Maximum number of backups to keep


# Initialize Firebase Admin SDK
def initialize_firebase():
    cred = credentials.Certificate(r"C:\Users\Akos\Desktop\projectztt-firebase-adminsdk-fbsvc-16d783e108.json")  # Firebase Admin SDK JSON location
    firebase_admin.initialize_app(cred, {
        'databaseURL': 'https://projectztt-default-rtdb.firebaseio.com/'  # Your database URL
    })


def fetch_entire_database():
    ref = db.reference('/')
    data = ref.get()
    return data


def save_backup(data):
    # Create backup directory if it doesn't exist
    os.makedirs(output_dir, exist_ok=True)

    # Generate timestamped filename
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    backup_filename = f"backup_{timestamp}.json"
    backup_path = os.path.join(output_dir, backup_filename)

    # Save the backup
    with open(backup_path, 'w') as f:
        json.dump(data, f, indent=2)


    # Manage backup rotation
    manage_backup_rotation()


def manage_backup_rotation():
    # Get list of all backup files
    backups = [f for f in os.listdir(output_dir) if f.startswith('backup_') and f.endswith('.json')]

    # If we have more than max_backups, delete the oldest
    if len(backups) > max_backups:
        # Sort backups by creation time (oldest first)
        backups.sort(key=lambda x: os.path.getmtime(os.path.join(output_dir, x)))

        # Delete the oldest ones until we're at max_backups
        while len(backups) > max_backups:
            oldest_backup = backups.pop(0)
            os.remove(os.path.join(output_dir, oldest_backup))


def main():
    try:
        initialize_firebase()
        data = fetch_entire_database()

        # Save three backups (for demonstration)
        for i in range(3):
            save_backup(data)

    except Exception as e:
        print(f"Error: {str(e)}")


if __name__ == "__main__":
    main()