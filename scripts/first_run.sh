USER=${USER:-super}
PASS=${PASS:-$(pwgen -s -1 16)}

pre_start_action() {
  # Echo out info to later obtain by running `docker logs container_name`
  echo "POSTGRES_USER=$USER"
  echo "POSTGRES_PASS=$PASS"
  echo "POSTGRES_DATA_DIR=$DATA_DIR"

  # test if DATA_DIR has content
  if [[ ! "$(ls -A $DATA_DIR)" ]]; then
      echo "Initializing PostgreSQL at $DATA_DIR"

      # Copy the data that we generated within the container to the empty DATA_DIR.
      cp -R /var/lib/postgresql/9.3/main/* $DATA_DIR
  fi

  # Ensure postgres owns the DATA_DIR
  chown -R postgres $DATA_DIR
  # Ensure we have the right permissions set on the DATA_DIR
  chmod -R 700 $DATA_DIR
}

post_start_action() {
  echo "Creating the superuser: $USER"

  su postgres -c "psql -e -c 'create role $USER superuser createdb createrole inherit login with encrypted password $PASS'"

  rm /firstrun
}
