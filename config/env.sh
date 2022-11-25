#!/bin/bash

if [ -f "./index.html" ]; then
  # Recreate config file
  export ENV_VERSION=${RANDOM}
  echo "New container env version is =" $ENV_VERSION

  # Environment to .env file
  echo "DYNAMIC_ENV=" $REACT_APP_API > .env
  echo "BASE_API_URL=" $HTTPS >> .env

  # Add assignment
  echo "window._env_ = {" >> ./dynamic-env_${ENV_VERSION}.js

  # Read each line in .env file
  # Each line represents key=value pairs
  while read -r line || [[ -n "$line" ]];
  do
    # Split env variables by character `=`
    if printf '%s\n' "$line" | grep -q -e '='; then
      varname=$(printf '%s\n' "$line" | sed -e 's/=.*//')
      varvalue=$(printf '%s\n' "$line" | sed -e 's/^[^=]*=//')
    fi

    # Read value of current variable if exists as Environment variable
    value=$(printf '%s\n' "${!varname}")
    # Otherwise use value from .env file
    [[ -z $value ]] && value=${varvalue}

    # Append configuration property to JS file
    echo "  $varname: \"$value\"," >> ./dynamic-env_${ENV_VERSION}.js
  done < .env

  echo "}" >> ./dynamic-env_${ENV_VERSION}.js
  rm .env
  sed -i "s/dynamic-env.js/$(echo dynamic-env_${ENV_VERSION}.js)/" index.html
  mv /usr/share/nginx/html/index.html /usr/share/nginx/html/index-${ENV_VERSION}.html
  sed -i "s/index.html/$(ls | grep index)/" /etc/nginx/conf.d/default.conf
else
  echo "Old container"
fi
